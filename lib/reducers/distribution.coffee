log = require '../log'

module.exports = ->
  [
    {}
    (memo, data)->
      memo[data] = (memo[data] ? 0) + 1
      memo
  ]
