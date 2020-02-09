sum = require '../reducers/sum'

module.exports = (data)->
  if data instanceof Array
    return data.reduce sum()
    
  data

