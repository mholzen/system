{NotMapped} = require '../../lib/errors'
{filepath, content} = require '../../lib/mappers'

{promisify} = require 'util'
fs = require 'fs'
{join} = require 'path'
stat = promisify fs.stat
lstat = promisify fs.lstat
stream = require '../../lib/stream'
{create} = require './traverse'

node = (start, options)->
  statFunc = if options?.followSymlinks? then stat else lstat

  (data, path)->
    fp = filepath data, base: start
    if not fp?
      throw new NotMapped data, 'filepath'
    try
      value = await statFunc fp
    catch e
      log.error 'stat', {e}
      value = null

    path ?= []
    if value? and not value.isDirectory()
      return [value, path]

    if data?
      path = path.concat data
    edges = for e from await content fp
      d = join (data ? ''), e
      p = path.concat e
      [d, p]

    return [value, edges]

module.exports = (data, options)->
  if options?.req?.dirname?
    data = options.req.dirname

  stream (push)->
    traverse = create
      node: node data, options
      push: push
      valueName: 'stat'

    await traverse()
    push null, stream.nil
