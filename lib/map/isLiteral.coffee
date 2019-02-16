log = require '@vonholzen/log'
{isStream} = require '../stream'

isLiteral = (data)->
  if isStream data
    return false

  if typeof resources[Symbol.iterator] != 'function'
    return false

  true

module.exports = isLiteral
