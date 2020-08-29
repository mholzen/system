log = require '@vonholzen/log'
{isStream} = require '../stream'

isLiteral = (data)->
  if isStream data
    return false

  if ['string', 'number', 'boolean', 'symbol'].includes typeof data
    return true

  if typeof data[Symbol.iterator] != 'function'
    return false

  true

module.exports = isLiteral
