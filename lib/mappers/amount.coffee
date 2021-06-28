amountField = require './amountField'
sign = require './sign'
_ = require 'lodash'

amount = (data, opts)->
  s = 1
  if typeof data == 'object'
    field = if opts?.field? then opts.field else amountField data
    if not field?
      throw new Error "no numeric field in #{log.print data}"

    n = _.toNumber data[field]

    s = sign data
    return n * s

  _.toNumber data

module.exports = amount
