log = require '../../lib/log'
mappers = require '../../lib/mappers'
isPromise = require 'is-promise'
args = require '../../lib/mappers/args'
Path = require 'path'
{content} = require '../../lib/mappers'
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

paths =
  Graph: '~/develop/mholzen/system/lib/mappers/templates/graph.html'

resolveNameOption = (options, option)->
  name = options?[option]?.name
  if name? and name of paths
    options[option].path = expandTilde paths[name]
  return options

resolvePathOption = (options, option, req)->
  path = options?[option]?.path
  if path? and req?.dirname?
    # log.debug 'resolvePathOption', {dirname: req.dirname, path, options}
    if not path.startsWith '/'
      path = Path.join req.dirname, path
    promise = content {path}, parse:'string'
    options[option] = await promise
    # log.debug 'resolvePathOption content retrieved', {options}
    return options
  else
    return new Promise (resolve)-> resolve options

handler = (req, res)->
  if not req.data?
    return res.status(400).send 'no data'

  if isStream req.data
    req.data = req.data.collect().toPromise Promise

  data = if isPromise req.data then await req.data else req.data

  part = req.remainder.shift()
  [name, words...] = part.split ','

  if not (name?.length > 0)
    req.data =
      req_data: req.data
      'property': Object.getOwnPropertyNames data
      'req.data.functions': functions data
      'mappers': Object.keys mappers
    return

  options = args words
  options = resolveNameOption options, 'template'

  # if any options require an filesystem, resolve these now
  options = await resolvePathOption options, 'template', req

  # add request and response to the context for this handler
  options.req = req
  options.res = res

  mapper = mappers name, options
  if not mapper?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof mapper != 'function'
    req.data = mapper
    return

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  positional = args.positional options
  getArgs = ->
    if not positional?
      return [ options ]
    if positional instanceof Array
      return [ positional..., options ]
    [ positional, options ]

  applyArgs = [ req.data ].concat getArgs()
  req.data = mapper.apply req.data, applyArgs

module.exports = handler