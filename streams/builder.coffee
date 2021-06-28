{NotFound} = require '../lib/errors'
stream = require '../lib/stream'
mappers = require '../lib/mappers'
generators = require './generators'
_ = require 'lodash'

root = {
  mappers
  generators
}

getOperator = (name)->
  if name of stream
    return stream[name]
  throw new NotFound name, stream

getFunc = (name)->
  func = _.get root, name
  if func?
    return func
  throw new NotFound name, root

segment = (data)->
  [operatorName, funcName...] = data.split ','
  operator = getOperator operatorName
  func = getFunc funcName[0]
  operator func

build = (array...)->
  pipe = array.map segment
  stream.pipeline pipe...

module.exports = build