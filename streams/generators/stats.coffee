{asyncTraverse} = require '../../lib/iterators/traverse'
{NotMapped} = require '../../lib/errors'
{filepath, content} = require '../../lib/mappers'

fs = require 'fs/promises'
{join} = require 'path'
stat = fs.stat
lstat = fs.lstat
stream = require '../../lib/stream'
{create} = require './traverse'

nodeCreator = (start, options)->
  statFunc = if options?.followSymlinks? then stat else lstat

  (data)->
    fp = filepath data, base: start
    if not fp?
      throw new NotMapped data, 'filepath'
    try
      if fp instanceof Array
        fp = join fp
      value = await statFunc fp
    catch e
      log.error 'stat', {e}
      value = null

    if value? and not value.isDirectory()
      return {value, edges: []}

    edges = await content fp

    return {value, edges}



module.exports = (data, options)->
  if options?.req?.dirname?
    data = options.req.dirname

  asyncIt = asyncTraverse '',
    node: nodeCreator data, options
    follow: (data, edge)-> join data, edge

  stream (push, next)->
    for await i from asyncIt
      push null, i
    push null, stream.nil
  .map (x)->    # TODO: can this be a mapper?
    x.stat = x.value
    x

module.exports.nodeCreator = nodeCreator