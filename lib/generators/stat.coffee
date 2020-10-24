{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat

stream = require '../stream'

module.exports = (data, options)->
  if typeof data == 'string'
    return stream stat data