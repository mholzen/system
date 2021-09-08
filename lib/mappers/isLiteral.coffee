isLiteral = (data)->
  if data == null
    return true
  if ['string', 'number', 'boolean', 'symbol'].includes typeof data
    return true

  false

Object.assign isLiteral,
  parameters: [
    name: '0'
    type: ['null', 'boolean', 'object', 'array', 'number', 'string']
  ]
  responses:
    default:
      description: "a boolean value representing whether the argument is a literal"
      content:
        "text/plain": {}
        "application/json":
          type: 'boolean'

module.exports = isLiteral
