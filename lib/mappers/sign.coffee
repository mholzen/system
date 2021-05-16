amountField = require './amountField'

signField = (data)->
  ['Transaction Type'].find (f)-> f of data

sign = (data, opts)->
  if typeof data == 'object'
    field = if opts?.field? then opts.field else signField data
    if not field?
      if (field = amountField data)?
        return Math.sign _.toNumber data[field]

      throw  new Error "no sign field in #{log.print data}"
  
    data = data[field]

  if typeof data == 'string'
    switch data.toLowerCase()
      when 'debit'
        return -1
      when 'credit'
        return 1
      else
        throw new Error "cannot understand #{data}"

sign.field = signField
module.exports = sign