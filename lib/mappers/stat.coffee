log = require '../log'
{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
path = require 'path'

filepath = (data, options)->
  if typeof data == 'string'
    return data

  if typeof data?.path == 'string'
    return data?.path

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return path.join directory, data.name

module.exports = (data, options)->
  data = filepath data,  options
  if data?
    log.debug 'stat', {data}
    return stat data