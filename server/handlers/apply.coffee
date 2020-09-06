log = require '../../lib/log'
mappers = require '../../lib/mappers'
isPromise = require 'is-promise'
args = require '../../lib/mappers/args'
path = require 'path'

functions = (obj) ->
  properties = new Set()
  currentObj = obj
  while currentObj?
    Object.getOwnPropertyNames currentObj
    .map (item)-> properties.add item
    currentObj = Object.getPrototypeOf currentObj

  return [...properties.keys()].filter (item) -> typeof obj[item] == 'function'

handler = (req, res)->

  if not req.data?
    return res.status(400).send 'no data'

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

  # add request and response to the context for this handler
  options.req = req
  options.res = res

  getFunction = ->
    # if the request has a filename
    if req.filename?
      # if the name refers to a file in the directory of the resource
      source = path.join(path.dirname req.filename, name)

      # if inodes(source) and (f = compile(source))
      #   return f

    mappers name, options

  f = getFunction()
  if not f?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof f != 'function'
    req.data = f
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
  # log.debug 'apply', {applyArgs}   # TODO: this takes 12 seconds (because of circular references?)

  req.data = f.apply req.data, applyArgs

module.exports = handler