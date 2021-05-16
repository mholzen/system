_ = require 'lodash'
sign = require './sign'
amountField = require './amountField'

amount = (data, opts)->
  s = 1
  if typeof data == 'object'
    f = opts?.field ? amountField data
    if not f?
      throw new Error "no numeric field in #{data}"
    n = _.toNumber data[f]

    s = sign data
    return n * s

  _.toNumber data

module.exports = amount
