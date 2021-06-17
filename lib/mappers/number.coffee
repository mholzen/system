module.exports = (value)->
  if typeof value == 'string'
    return Number.parseFloat value
    
  value

