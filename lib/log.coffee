log = require '@vonholzen/log'
{isStream} = require './stream'
isPromise = require 'is-promise'
_ = require 'lodash'

log.filter = (data)->
  if isPromise data
    return '<Promise>'

  if isStream data
    return '<Stream>'
  return data

log.defaultLength = 600

module.exports = log
