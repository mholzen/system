amount = require '../mappers/amount'

create = (options)->
  (memo, data)->
    memo ?= 0
    memo += amount data, options
    memo

module.exports = create()
