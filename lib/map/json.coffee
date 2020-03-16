isPromise = require 'is-promise'
{isStream} = require '../stream'

defaultReplacer = (key, value)->
  if isStream value
    return '<Stream>'
  if isPromise value
    return '<Promise>'
  if typeof value == 'function'
    return '<function>'

  if value instanceof Array
    return value

  if typeof value?[Symbol.iterator] == 'function'
    if typeof value?.entries == 'function'
      return Object.fromEntries value.entries()

  value

module.exports = (data, options)->
  replacer = options?.replacer ? defaultReplacer
  JSON.stringify data, replacer
