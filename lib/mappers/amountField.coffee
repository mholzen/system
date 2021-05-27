isNumber = require './isNumber'

module.exports = (data)->
  field = ['amount', 'Amount'].find (f)-> f of data
  if field?
    return field

  for k, v of data
    if isNumber v
      return k