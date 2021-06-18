log = require '../../lib/log'
mappers = require '../../lib/mappers'
isPromise = require 'is-promise'
{Arguments} = require '../../lib/mappers/args'
Path = require 'path'
{content, value} = require '../../lib/mappers'
{isStream} = require '../../lib/stream'
expandTilde = require 'expand-tilde'
objectPath = require '../../lib/path'
{NotProvided} = require '../../lib/errors'

functions = (obj) ->
  properties = new Set()
  currentObj = obj
  while currentObj?
    Object.getOwnPropertyNames currentObj
    .map (item)-> properties.add item
    currentObj = Object.getPrototypeOf currentObj

  return [...properties.keys()].filter (item) -> typeof obj[item] == 'function'

# TODO: make accessible to the server
paths =
  Graph: '~/develop/mholzen/system/lib/mappers/templates/graph.html'
  Graph2: '~/develop/mholzen/system/lib/mappers/templates/graph2.html'
  Image: '~/develop/mholzen/system/lib/mappers/templates/image.html'
  Table: '~/develop/mholzen/vonholzen.org/files/private/table.pug'
  Element: '~/develop/mholzen/vonholzen.org/files/elements/element.pug'

resolveNameOption = (options, option)->
  name = options?[option]?.name
  if name? and name of paths
    options[option].path = expandTilde paths[name]
  return options

resolvePathOption = (options, option, req)->
  path = options?[option]?.path
  # log.debug 'resolvePathOption', {options, option, path}
  if path?
    if not path.startsWith '/'
      if not req?.dirname?
        throw new Error "relative path '#{path}' but no req.dirname"
      path = Path.join req.dirname, path
    options[option].path = path
    options[option].content = await content {path}, parse:'string'
    # log.debug 'resolvePathOption content retrieved', {[option]: options[option]}
    return options
  else
    return new Promise (resolve)-> resolve options


getArgs = (req)->
  if req.args?.positional?.length > 0
    # log.debug 'getArgs return using req.args', {args: req.args}
    return req.args

  part = req.remainder.shift()
  # log.debug 'getArgs consuming req.remainder', {part, remainder: req.remainder}
  if not (part?.length > 0)
    throw new NotProvided 'req.remainder'
    
  args = Arguments.from part

module.exports = (req, res)->
  args = getArgs req
  name = args.first()

  # log.debug 'apply.enter', {name}
  if typeof req.data?[name] == 'function'
    # log.debug 'apply calling function of req.data'
    args.positional.shift() # remove name
    aa = [args.positional, args.options]
    req.data = req.data[name].apply req.data, aa...
    return

  path = objectPath args.all()
  path.follow mappers
  mapper = path.to
  args = Arguments.from path.remainder()

  if not mapper?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  # log.debug 'apply found', {mapper}
  if typeof mapper != 'function'
    req.data = mapper
    return

  #
  # augment and resolve `options`
  #
  resolveNameOption args.options, 'template'
  resolveNameOption args.options, 'style'

  # if any options require an filesystem, resolve these now
  args.options = await resolvePathOption args.options, 'template', req
  args.options = await resolvePathOption args.options, 'style', req

  # add request and response to the context for this handler
  Object.assign args.options, {req, res}

  a = args.all()
  # log.debug 'apply', {a}
  # mapper = mappers a...
  # mapper = target a...

  # perhaps mapper can handle that?
  # if isPromise req.data
  #   log.debug 'apply awaiting'
  #   req.data = await req.data

  log.debug "applying mapper '#{name}' to req.data of type #{typeof req.data}: '#{log.print req.data}'"
  # req.data = mapper.apply req.data, [ req.data ]
  a.unshift req.data
  # req.data = await mapper.apply req.data, a
  req.data = mapper.apply req.data, a
  log.debug "apply.exit", {data: req.data}
  req.data

module.exports.description = 'handlers/apply'