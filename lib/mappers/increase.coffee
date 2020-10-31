log = require '../log'

module.exports = (data, options)->
  if typeof data == 'number'
    return data+1