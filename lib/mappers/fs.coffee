log = require '../log'
{promisify} = require 'util'
fs = require 'fs'
path = require 'path'
creator = require '../creator'

filepath = (data, options)->
  if typeof data == 'string'
    return data

  if typeof data?.path == 'string'
    return data?.path

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return path.join directory, data.name

call = (f)->
  pf = promisify f
  (data, options...)->
    fp = filepath data, options...
    if fp?
      log.debug 'fs', {filepath: fp, func: f}
      pf fp

functions = creator
  readlink: call fs.readlink
  stat: call fs.stat
  lstat: call fs.lstat

module.exports = functions

# module.exports = (data, name, options)->
#   data = filepath data,  options
#   if data?
#     f = functions name
#     log.debug 'fs', {name, f, data}
#     f data