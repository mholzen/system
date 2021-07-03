{isStream} = require '../stream'

isLiteral = (data)->
  if ['string', 'number', 'boolean', 'symbol'].includes typeof data
    return true

  false

isLiteral.returns =
  type: 'Boolean'

module.exports = isLiteral
