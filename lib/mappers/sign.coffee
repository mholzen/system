amountField = require './amountField'

field = (data)->
  ['Transaction Type'].find (f)-> f of data

sign = (data, opts)->
  if typeof data == 'object'
    f = opts?.field ? field data
    if not f?
      if (f = amountField data)?
        return Math.sign _.toNumber data[f]

      throw  new Error "no sign field in #{log.print data}"
  
    data = data[f]

  if typeof data == 'string'
    switch data.toLowerCase()
      when 'debit'
        return -1
      when 'credit'
        return 1
      else
        throw new Error "cannot understand #{data}"

sign.field = field
module.exports = sign