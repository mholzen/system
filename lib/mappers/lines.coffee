{NotMapped} = require '../errors'
content = require './content'

module.exports = (data, options)->
  if data instanceof Buffer
    data = data.toString()

  if typeof data == 'string'
    return data.split '\n'
  
  throw new NotMapped data, 'lines'