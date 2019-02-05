log = require '@vonholzen/log'
stream = require './stream'
_ = require 'lodash'

log.filter = (object)->
  if object instanceof Error
    return object

  result = {}
  for k,v of object
    if stream.isStream(v)
      v = '<stream>'
    if typeof v != 'function'
      result[k] = v
  # _.pickBy object, (v,k) ->
  return result

module.exports = log
