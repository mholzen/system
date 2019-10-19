log = require '../log'
_ = require 'lodash'

amount = require '../map/amount'

sum = (opts)->
  (x, y)->
    x = amount x, opts
    y = amount y, opts

    x + y

module.exports = sum
