log = require '@vonholzen/log'
{isStream} = require './stream'
_ = require 'lodash'

log.filter = (data)->
  if isStream data
    return '<stream>'

  if data instanceof Error
    return data

  if typeof data != 'object'
    return data

  result = {}
  for k,v of data
    if isStream(v)
      v = '<stream>'

    if v instanceof RegExp
      v = v.toString()

    if typeof v != 'function'
      result[k] = v
  # _.pickBy data, (v,k) ->
  return result

module.exports = log
