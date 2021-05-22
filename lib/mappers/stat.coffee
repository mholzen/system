# TODO: refactor to use mappers.fs.stat
{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
lstat = promisify fs.lstat
path = require 'path'
filepath = require './filepath'

module.exports = (data, options)->
  # log.debug 'stat.entry', {data}
  data = filepath data,  options
  if data?
    f = if options.symlink? then lstat else stat
    # log.debug 'stat', {data, f}
    f data