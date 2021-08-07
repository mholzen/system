{promisify} = require 'util'
fs = require 'fs'
creator = require '../creator'
filepath = require './filepath'

call = (func)->
  pfunc = promisify func
  (data, options...)->
    fp = filepath data, options...
    if fp?
      # log.debug 'fs', {filepath: fp, func: f}
      pfunc fp

functions = # creator
  readlink: call fs.readlink
  stat: call fs.stat
  lstat: call fs.lstat

module.exports = functions
