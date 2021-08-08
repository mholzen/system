{NotMapped} = require '../../lib/errors'
isPromise = require '../../lib/mappers/isPromise'
isStream = require '../../lib/mappers/isStream'
augmentArgsMapper = require './augmentArgsMapper'

reduce = (data, func)->
  if data instanceof Array
    return data.reduce func, null

  if isStream data
    return data.reduce null, func

  throw new NotMapped data, 'reduce function'

module.exports = (req, res, router)->
  augmentArgsMapper req, res
  func = req.mapper
  args = req.args

  if not req.data?
    return res.status(400).send 'no data'

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  if req.data instanceof Buffer
    if res.get('Content-Type').startsWith 'text/csv'
      # TODO: generalize type "inference"
      req.data = req.data.toString().split '\n'

  a = args.all()
  # log 'reduce', {data: req.data}
  req.data = reduce req.data, func
  # req.data = reducers.reduce @, a...
