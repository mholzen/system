isPromise = require 'is-promise'
{isStream} = require '../stream'

defaultReplacer = (key, value)->
  if isStream value
    return '[Stream]'
  if isPromise value
    return '[Promise]'

  value

module.exports = (opts)->
  opts ?= {}
  replacer = opts.replacer ? defaultReplacer
  (data)->
    JSON.stringify data, replacer
