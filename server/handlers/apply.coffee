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
getFunction = require '../../lib/mappers/function'
augmentArgsMapper = require './augmentArgsMapper'
request = require '../request'

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

# resolveNameOption = (options, option)->
#   name = options?[option]?.name
#   if name? and name of paths
#     options[option].path = expandTilde paths[name]
#   return options

# resolvePathOption = (options, option, req)->
#   path = options?[option]?.path
#   # log.debug 'resolvePathOption', {options, option, path}
#   if path?
#     if not path.startsWith '/'
#       if not req?.dirname?
#         throw new Error "relative path '#{path}' but no req.dirname"
#       path = Path.join req.dirname, path
#     options[option].path = path
#     options[option].content = await content {path}, parse:'string'
#     # log.debug 'resolvePathOption content retrieved', {[option]: options[option]}
#     return options
#   else
#     return new Promise (resolve)-> resolve options


# getArgs = (req)->
#   if req.args?.positional?.length > 0
#     # log.debug 'getArgs return using req.args', {args: req.args}
#     return req.args

#   part = req.remainder.shift()
#   if not (part?.length > 0)
#     throw new NotProvided 'req.remainder'
    
#     # req.data =
#     #   data: req.data
#     #   'properties': Object.getOwnPropertyNames data
#     #   'functions': functions data
#     #   'mappers': Object.keys mappers
#     # return

#   args = Arguments.from part

resolveArg = (arg, options)->
  if not (arg instanceof Array)
    return arg
  
  if arg?[0] != ''
    return arg

  first = arg[1] if arg?[1]?

  if options.req.params.root.handlers[first]?
    return await options.req.params.router.subprocess arg

  return arg

  # throw new Error "can't resolve #{arg} of type '#{typeof arg}"


module.exports = (req, res)->
  if isStream req.data
    req.data = req.data.collect().toPromise Promise

  data = if isPromise req.data then await req.data else req.data

  augmentArgsMapper req, res
  mapper = req.mapper
  args = req.args

  if not mapper?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof mapper != 'function'
    req.data = mapper
    return

  # Object.assign args.options, {req, res}

  if args.positional.length > 0
    for p, i in args.positional
      args.positional[i] = await resolveArg p, args.options
  

  a = args.all()

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  # log "applying mapper '#{name}' to req.data of type #{typeof req.data}: '#{log.print req.data}'"
  # req.data = mapper.apply req.data, [ req.data ]
  a.unshift req.data
  log 'apply', {args: a}
  req.data = await mapper.apply @, a
