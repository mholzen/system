moment = require 'moment'

text = (value, context)->
  if typeof value == 'object'
    result = {}
    for k, v of value
      Object.assign result, "#{k}": text(v, k)
    return result

  switch context
    when 'date_added', 'date', 'date_modified'
      moment(parseInt(value)/1000).subtract(1970-1601, 'years').fromNow()
    else
      value

module.exports = text
