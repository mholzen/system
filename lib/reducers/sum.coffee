log = require '../log'

amount = require '../mappers/amount'

sum = (memo, value)->
  log.debug 'sum', {memo, value}
  memo ?= 0
  memo += amount value
  memo

module.exports = sum