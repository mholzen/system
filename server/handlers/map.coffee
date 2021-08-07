{NotProvided} = require '../../lib/errors'
{
  mappers
  stream
} = require '../../lib'
{parse} = require '../../streams/transformers'

isPromise = require 'is-promise'
{Arguments} = mappers.args
augmentArgsMapper = require './augmentArgsMapper'

module.exports = (req, res, router)->
  augmentArgsMapper req, res
  func = req.mapper
  args = req.args

  if typeof func != 'function'
    req.data = func
    return

  if not req.data?
    return res.status(400).send 'no data'

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  if req.data instanceof Array
    req.data = stream req.data

  isMap = mappers.isMap req.data
  if isMap  
    keys = mappers.keys req.data
    req.data = mappers.values req.data
    # log.debug 'map.first', {f: req.data[0]}

  catchAndLog = (f)->
    (currentValue, index, array)->
      try
        # log.debug 'map', {currentValue, index, array}
        args.options.index = index
        args.options.array = array
        a = args.all()
        # log.debug {args: a}
        f currentValue, a...
      catch e
        log.error 'map', {e: e.stack}
        # TODO; use a toggle to return the exception or fail
        return e

  g = catchAndLog func
  req.data = req.data.map g

  if isMap
    req.data = keys.reduce (m, k, i)->
      m[k] = req.data[i]
      m
    , {}
