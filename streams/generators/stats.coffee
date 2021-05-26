{NotMapped} = require '../../lib/errors'
{filepath, content} = require '../../lib/mappers'

{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
lstat = promisify fs.lstat
stream = require '../../lib/stream'
{create} = require './traverse'

# TODO: move to mappers
edges = (options)->
  statFunc = if options?.followSymlinks? then stat else lstat

  (data)->
    # TODO: edges now async
    fp = filepath data
    s = await statFunc fp
    if not s.isDirectory()
      # log.debug 'edges.exit', {data}
      return []

    res = await content fp
    # log.debug 'edges.exit', {res}
    return res

# TODO: move to mappers
value = (options)->
  statFunc = if options?.followSymlinks? then stat else lstat

  (data)->
    fp = filepath data
    if not fp?
      throw new NotMapped data, 'filepath'
    await statFunc fp

module.exports = (data, options)->
  if options?.req.dirname?
    data = options.req.dirname

  stream (push, next)->
    traverse = create
      value: value options
      edges: edges options
      push: push
      next: next
    await traverse data
    push null, stream.nil
