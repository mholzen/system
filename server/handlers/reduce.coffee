{reducers, log} = require '../../lib'
{Arguments} = require '../../lib/mappers/args'
isPromise = require 'is-promise'

module.exports = (req, res, router)->
  segment = req.remainder.shift()
  if not (segment?.length > 0)
    req.data = Object.keys(reducers).sort()
    return

  args = Arguments.from segment
  name = args.first()

  if not (reducer = reducers[name])
    return res.status(404).send "'#{name}' not found"

  if not req.data?
    return res.status(400).send 'no data'

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  if req.data instanceof Buffer
    req.data = req.data.toString()

  Object.assign args.options, {req, res}

  a = args.all()
  req.data = reducers.reduce req.data, a...
