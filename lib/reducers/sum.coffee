amount = require '../mappers/amount'

module.exports =
  create: ->
    (memo, data)->
      memo ?= 0
      memo += amount data
      memo
