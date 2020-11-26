log = require '../log'
{promisify} = require 'util'
fs = require 'fs'
path = require 'path'

functions =
  readlink: promisify fs.readlink
  stat: promisify fs.stat
  lstat: promisify fs.lstat

filepath = (data, options)->
  if typeof data == 'string'
    return data

  if typeof data?.path == 'string'
    return data?.path

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return path.join directory, data.name

module.exports = (data, name, options)->
  data = filepath data,  options
  if data?
    f = functions[name]
    log.debug 'fs', {name, f, data}
    f data