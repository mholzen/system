{objectEdges, objectValue} = require '../../lib/traverse'
stream = require '../../lib/stream'
{join} = require 'path'

create = (options)->
  # log.debug 'traverse', {options}
  value = options?.value ? objectValue
  edges = options?.edges ? objectEdges
  push = options?.push
  next = options?.next

  traverse = (data, path)->
    path ?= []
    # log.debug 'traverse.start', {data}
    try
      v = await value data

      if v != null
        if not options?.noPath
          v = {value: v, path}
        push null, v
        log.debug 'traverse.push', {value: v}

      for e from await edges data
        d = join data, e
        p = path.concat e
        log.debug 'traverse.edges', {e, d}
        await traverse d, p
        # for i from await traverse d
        #   if not options?.noPath
        #     i.path.unshift e
        #   log.debug 'traverse.push', {value: i}
        #   push null, v

      # log.debug 'traverse.next'
      # next()    # not needed because this stream will only consume one input (?)
      return
    catch e
      log.debug 'traverse.catch', {e}
      push e, null

  return traverse

module.exports = Object.assign create(), {objectEdges, objectValue, create}
