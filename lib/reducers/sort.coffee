log = require '../log'

score = (a,b) ->
  # TODO: find first numerical column in a anb b, using 1 for now.
  b[1] - a[1]   # highest score first

sort = -> [
  [[,-Infinity]]
  (memo,value)->score memo, value
]

module.exports = Object.assign sort, {score}
