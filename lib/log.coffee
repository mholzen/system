log = require '@vonholzen/log'
{isStream} = require './stream'
isPromise = require 'is-promise'
_ = require 'lodash'

log.filter = (data)->
  if typeof data == 'undefined'
    return '<undef>'
  if data == null
    return '<null>'
  if (typeof data == 'string') and data == ''
    return "''"

  if data?.type == 'file'
    return "<File #{data.path}>"

  if data?.type == 'directory'
    return "<Dir #{data.path}>"

  if isPromise data
    return '<Promise>'

  if isStream data
    return '<Stream>'
  return data

log.defaultLength = 600

module.exports = log
