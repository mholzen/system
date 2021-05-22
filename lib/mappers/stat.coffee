{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
lstat = promisify fs.lstat
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
  # log.debug 'stat.entry', {data}
  data = filepath data,  options
  if data?
    f = if options.symlink? then lstat else stat
    # log.debug 'stat', {data, f}
    f data