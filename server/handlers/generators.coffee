{
  generators
  log
} = require '../../lib'
isPromise = require 'is-promise'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  if not (name?.length > 0)
    req.data = Object.keys(generators).sort()
    return

  if not (generator = generators name, {req})
    return res.status(404).send "'#{name}' not found"

  if not req.data?
    return res.status(400).send 'no data'

  if isPromise req.data
    req.data = await req.data

  if req.data instanceof Buffer
    req.data = req.data.toString()

  req.data = generator req.data
  log.debug 'generator', {output: req.data, name: req.name}
  req.data
