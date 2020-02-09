capitalize = require 'capitalize'

person = (value)->
  if typeof value == 'string'
    value = value.replace /\./g, ' '
    value = capitalize.words value
    
  value

module.exports = person
