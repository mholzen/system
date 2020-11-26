log = require '../../lib/log'
mappers = require '../../lib/mappers'
isPromise = require 'is-promise'
{Arguments} = require '../../lib/mappers/args'
Path = require 'path'
{content, value} = require '../../lib/mappers'
{isStream} = require '../../lib/stream'
expandTilde = require 'expand-tilde'

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
  Image: '~/develop/mholzen/system/lib/mappers/templates/image.html'
  Table: '~/develop/mholzen/vonholzen.org/files/private/table.pug'

resolveNameOption = (options, option)->
  name = options?[option]?.name
  if name? and name of paths
    options[option].path = expandTilde paths[name]
  return options

resolvePathOption = (options, option, req)->
  path = options?[option]?.path
  if path?
    log.debug 'resolvePathOption', {option}
    if not path.startsWith '/'
      if not req?.dirname?
        throw new Error "relative path '#{path}' but no req.dirname"
      path = Path.join req.dirname, path
    options[option].path = path
    options[option].content = await content {path}, parse:'string'
    log.debug 'resolvePathOption content retrieved', {[option]: options[option]}
    return options
  else
    return new Promise (resolve)-> resolve options

module.exports = (req, res)->
  if not req.data?
    return res.status(400).send 'no data'

  if isStream req.data
    req.data = req.data.collect().toPromise Promise

  data = if isPromise req.data then await req.data else req.data

  part = req.remainder.shift()
  if not (part?.length > 0)
    req.data =
      req_data: req.data
      'property': Object.getOwnPropertyNames data
      'req.data.functions': functions data
      'mappers': Object.keys mappers
    return

  args = Arguments.from part
  resolveNameOption args.options, 'template'
  resolveNameOption args.options, 'style'

  # if any options require an filesystem, resolve these now
  args.options = await resolvePathOption args.options, 'template', req
  args.options = await resolvePathOption args.options, 'style', req

  # add request and response to the context for this handler
  Object.assign args.options, {req, res}

  a = args.all()
  name = a[0]
  if typeof req.data[name] == 'function'
    args.positional.shift() # remove name
    # if args.positional[0]?   # TODO: do this for all positional
    #   args.positional[0] = value req.data, args.positional[0], args.options

    if args.positional[0] == 'score'   # TODO: do this for all positional
      args.positional[0] = req.root.reducers.sort.score

    log.debug "applying req.data.'{#name}' function"
    req.data = req.data[name].apply req.data, args.positional
    return

  mapper = mappers a...
  if not mapper?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof mapper != 'function'
    req.data = mapper
    return

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  log.debug "applying mapper '#{name}' to req.data" 
  req.data = mapper.apply req.data, [ req.data ]
