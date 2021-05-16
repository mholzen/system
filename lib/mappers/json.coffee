isPromise = require 'is-promise'
{isStream} = require '../stream'

defaultReplacer = (key, value)->
  if value instanceof Error
    return value.toString()

    # TODO: toggle on/off
    # return
    #   message: value.toString()
    #   stack: value.stack

      # TODO: understand why these don't work
      # fileName: value.fileName
      # lineNumber: value.lineNumber

  if isStream value
    return '<Stream>'
  if isPromise value
    return '<Promise>'
  if typeof value == 'function'
    return '<function>'

  if value instanceof Array
    return value

  if typeof value?[Symbol.iterator] == 'function'
    if value instanceof Set
      return Array.from value.values()

    if typeof value?.entries == 'function'
      return Object.fromEntries value.entries()

  value

module.exports = (data, options)->
  replacer = options?.replacer ? defaultReplacer
  if data instanceof Buffer
    data = data.toString()
  JSON.stringify data, replacer, options?.space

module.exports.defaultReplacer = defaultReplacer
