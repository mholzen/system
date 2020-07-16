_ = require 'lodash'

field = (x)->
  ['amount', 'Amount'].find (f)-> f of x

amount = (x, opts)->
  if typeof x == 'object'
    f = opts?.field ? field x
    if not f?
      throw new Error "no numeric field in ${x}"
    x = x[f]

  _.toNumber x

amount.field = field
module.exports = amount
