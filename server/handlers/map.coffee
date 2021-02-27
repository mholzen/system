{
  mappers
  stream
  log
} = require '../../lib'
{parse} = require '../../streams/transformers'

isPromise = require 'is-promise'
{Arguments} = mappers.args

module.exports = (req, res, router)->
  segment = req.remainder.shift()
  args = Arguments.from segment
  name = args.first()

  if not (name?.length > 0)
    req.data = Object.keys(mappers).sort()
    return

  if not (f = mappers name)?
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
    req.data = stream([req.data]).through parse()

  if req.data instanceof Array
    req.data = stream req.data

  Object.assign args.options, {req, res, resolve: mappers}

  catchAndLog = (f)->
    (a...)->
      try
        f a...
      catch e
        log.error {e}
        null

  a = args.all()
  f = mappers a...
  g = catchAndLog f
  req.data = req.data.map g