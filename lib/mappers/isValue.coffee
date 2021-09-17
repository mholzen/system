isStream = require './isStream'
isPromise = require './isPromise'
isLiteral = require './isLiteral'

module.exports = (data, key)->
  return true if isLiteral data
  return true if typeof data == 'function'
  return true if typeof data == 'undefined'
  return true if (isStream data)
  return true if (isPromise data)
  false
