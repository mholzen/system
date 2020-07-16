log = require '../log'

amount = require '../mappers/amount'

sum = (opts)->
  (x, y)->
    x = amount x, opts
    y = amount y, opts

    x + y

module.exports = sum
