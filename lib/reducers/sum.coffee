amount = require '../mappers/amount'

module.exports =
  create: (options)->
    (memo, data)->
      memo ?= 0
      memo += amount data, options
      memo
