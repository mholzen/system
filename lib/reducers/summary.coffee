log = require '../log'

module.exports = -> [
  {count: 0}
  (memo, data)->
    memo.count += 1
    memo
]