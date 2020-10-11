{
  reducers
  log
} = require '../../lib'
isPromise = require 'is-promise'

module.exports = (req, res, router)->
  name = req.remainder.shift()
  if not (name?.length > 0)
    req.data = Object.keys(reducers).sort()
    return

  if not (reducer = reducers[name])
    return res.status(404).send "'#{name}' not found"

  if not req.data?
    return res.status(400).send 'no data'

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  if req.data instanceof Buffer
    req.data = req.data.toString()

  options = {req, res}

  req.data = reducers.reduce req.data, name, options
