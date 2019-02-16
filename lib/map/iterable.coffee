log = require '@vonholzen/log'
{isStream} = require '../stream'

module.exports = (data)->
  if isStream data
    return true

  if typeof data?[Symbol.iterator] == 'function'
    return true

  false
