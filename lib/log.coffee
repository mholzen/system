log = require '@vonholzen/log'
{isStream} = require './stream'
isPromise = require 'is-promise'
isRequest = require './mappers/isRequest'
isResponse = require './mappers/isResponse'

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

  if isRequest data
    return '<Request params:' + log.print(data.params) + '>'

  if isResponse data
    return '<Response>'

  if data instanceof Buffer
    return '<Buffer>'

  if data instanceof Set
    return '{' + Array.from(data.values()).join(',') + '}'

  return data

log.defaultLength = 600

module.exports = log
