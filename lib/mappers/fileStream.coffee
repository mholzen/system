fs = require 'fs'
filepath = require './filepath'

module.exports = (data, options)->
  fs.createReadStream filepath data, options