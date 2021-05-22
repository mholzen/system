{NotMapped} = require '../errors'
{filepath} = require '../mappers'

{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
stream = require '../stream'
{create} = require '../traverse'

edges = (data)->
  fp = filepath data
  if not fp?
    throw new NotMapped data, 'filepath'

# TODO: edges now async
  s = await stat fp
  if not s.isDirectory()
    return

  content fp

value = (data)->
  fp = filepath data
  if not fp?
    throw new NotMapped data, 'filepath'
  fp

module.exports = (data, options)->
  traverse = create {value, edges}
  stream traverse data