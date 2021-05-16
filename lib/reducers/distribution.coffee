module.exports = 
  create: ->
    (memo, data)->
      memo ?= {}
      memo[data] = (memo[data] ? 0) + 1
      memo
