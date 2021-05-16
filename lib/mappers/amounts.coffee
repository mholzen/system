amount = require './amount'

module.exports = (data, options)->
  if data instanceof Array
    return data.map amount
  
  throw new Error 'cannot make amounts'