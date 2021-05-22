{promisify} = require 'util'
fs = require 'fs'
creator = require '../creator'

call = (f)->
  pf = promisify f
  (data, options...)->
    fp = filepath data, options...
    if fp?
      # log.debug 'fs', {filepath: fp, func: f}
      pf fp

functions = creator
  readlink: call fs.readlink
  stat: call fs.stat
  lstat: call fs.lstat

module.exports = functions
