{
  mappers
  stream
  log
} = require '../../lib'
isPromise = require 'is-promise'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  if not (name?.length > 0)
    req.data = Object.keys(mappers).sort()
    return

  if not (f = mappers[name])?
    return res.status(404).send "'#{name}' not found"

  if typeof f != 'function'
    req.data = f
    return

  if not req.data?
    return res.status(400).send 'no data'

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  if req.data instanceof Buffer
    req.data = req.data.toString()

  if req.data instanceof Array
    req.data = stream req.data

  # log.debug 'apply f', {req_data: req.data, f:f}
  req.data = req.data.map (v)->
    f v, {filename: req.filename} # TODO: how is the second argument defined?

