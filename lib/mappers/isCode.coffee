filepath = require './filepath'

re = /\.(coffee|js)$/

module.exports = (data)->
  re.test filepath data
