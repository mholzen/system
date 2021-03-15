{isStream} = require '../stream'

isLiteral = (data)->
  if ['string', 'number', 'boolean', 'symbol'].includes typeof data
    return true

  false

module.exports = isLiteral
