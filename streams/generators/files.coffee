# TODO: delete?
stat = require '../../lib/mappers/stat'
{promisify} = require 'util'
fs = require 'fs'
readdir = promisify fs.readdir
path = require 'path'

module.exports = (data, options)->
  if Array.isArray data
    data = path.join data...

  if typeof data == 'string'
    s = await stat data

    # TODO: symlinks?

    # if data references a file, returns stat
    if s.isFile()
      return s

    # if data references a direction, returns list of names
    if s.isDirectory()
      return await readdir data