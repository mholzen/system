filepath = require './filepath'

re = /node_modules/

module.exports = (data)->
  re.test filepath data
