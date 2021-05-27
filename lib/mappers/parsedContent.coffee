content = require './content'
parse = require '../parse'

module.exports = (data, options)->
  data = await content data, options
  if data instanceof Buffer
    data = data.toString()
  parse data

