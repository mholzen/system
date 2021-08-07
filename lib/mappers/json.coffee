isPromise = require 'is-promise'
{isStream} = require '../stream'
isSocket = require './isSocket'
{Arguments} = require './args'

isServerResponse = require './isServerResponse'

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

  if isServerResponse value
    return '<ServerResponse>'
  if isSocket value
    return '<Socket>'
  if isStream value
    return '<Stream>'
  if isPromise value
    return '<Promise>'
  if typeof value?.emit == 'function'
    return '<EventEmitter>'
  if typeof value == 'function'
    return '<fn>'
  if value instanceof Arguments
    return '<Arguments>'

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
