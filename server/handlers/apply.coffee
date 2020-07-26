log = require '../../lib/log'
mappers = require '../../lib/mappers'
isPromise = require 'is-promise'

functions = (obj) ->
  properties = new Set()
  currentObj = obj
  while currentObj?
    Object.getOwnPropertyNames currentObj
    .map (item)-> properties.add item
    currentObj = Object.getPrototypeOf currentObj

  return [...properties.keys()].filter (item) -> typeof obj[item] == 'function'


module.exports = (req, res)->

  if not req.data?
    return res.status(400).send 'no data'

  data = if isPromise req.data then await req.data else req.data

  name = req.remainder.shift()
  if not (name?.length > 0)
    req.data =
      req_data: req.data
      isTable: req.data instanceof Table
      'property': Object.getOwnPropertyNames data
      'req.data.functions': functions data
      'mappers': Object.keys mappers
    return

  getFunction = (data)->
    if typeof data[name] == 'function'
      return data[name]
    if typeof mappers[name] == 'function'
      return mappers[name]

  if not (f = getFunction req.data)
    return res.status(404).send "'#{name}' not found"

  if typeof f != 'function'
    req.data = f
    return

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  options = {filename: req.filename}
  args = [ req.data, options ]

  # log.debug 'apply f', {data: req.data, f:f, options}
  req.data = f.apply req.data, args
