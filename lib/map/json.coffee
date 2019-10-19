isPromise = require 'is-promise'
{isStream} = require '../stream'

defaultReplacer = (key, value)->
  if isStream value
    return '[Stream]'
  if isPromise value
    return '[Promise]'
  if value instanceof Array
    return value

  if typeof value?[Symbol.iterator] == 'function'
    if typeof value?.entries == 'function'
      return Object.fromEntries value.entries()

  value

module.exports = (opts)->
  opts ?= {}
  replacer = opts.replacer ? defaultReplacer
  (data)->
    JSON.stringify data, replacer
