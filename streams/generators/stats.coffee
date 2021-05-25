{NotMapped} = require '../../lib/errors'
{filepath, content} = require '../../lib/mappers'

{promisify} = require 'util'
fs = require 'fs'
stat = promisify fs.stat
stream = require '../../lib/stream'
{create} = require './traverse'

edges = (data)->
  # TODO: edges now async
  fp = filepath data
  s = await stat fp
  if not s.isDirectory()
    log.debug 'edges.exit', {data}
    return []

  res = await content fp
  log.debug 'edges.exit', {res}
  return res

value = (data)->
  fp = filepath data
  if not fp?
    throw new NotMapped data, 'filepath'
  await stat fp

module.exports = (data, options)->
  if options?.req.dirname?
    data = options.req.dirname

  stream (push, next)->
    traverse = create {value, edges, push, next}
    await traverse data
    push null, stream.nil
