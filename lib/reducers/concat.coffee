log = require '../log'

module.exports = ->
  [
    []
    (memo, data)->
      memo.concat data
  ]
