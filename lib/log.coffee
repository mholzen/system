log = require '@vonholzen/log'
{isStream} = require './stream'
_ = require 'lodash'

log.filter = (data)->
  if isStream data
    return '<stream>'

  if typeof data?.then == 'function'
    return '<Promise>'

  if data instanceof Error
    return data

  if data instanceof Array
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

  return result

log.defaultLength = 600

module.exports = log
