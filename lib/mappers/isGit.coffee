filepath = require './filepath'

re = /\.git/

module.exports = (data)->
  re.test filepath data
