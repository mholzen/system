sum = require '../reducers/sum'

module.exports = (data, index, array)->
  if data instanceof Array
    return data.reduce sum, 0
    
  throw new Error "cannot reduce #{typeof data} '#{log.print data}'"