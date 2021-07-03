{objectEdges, objectValue} = require '../../lib/traverse'
stream = require '../../lib/stream'

objectNode = (data)->
  v = objectValue data
  e = objectEdges data
  return [v,e]

# TODO: dedup with lib/traverse to:efficient

create = (options)->
  node = options?.node ? objectNode
  # node(data) where data is a node or a node identifier
  # node() should returns [value, edges]
  push = options?.push
  valueName = options?.valueName ? 'value'

  traverse = (data, path)->
    path ?= []
    # log 'start', {data, path}
    try
      [v,edges] = await node data

      if v != null
        if not options?.noPath
          v = {[valueName]: v, path}
        push null, v
        # log 'push', {value: v}

      for e from edges
        [d,p] = e
        # log 'edges', {data: d, path: p}
        await traverse d, p
      return
    catch e
      # log 'catch', {e}
      push e, null

  return traverse

module.exports = Object.assign create(), {objectEdges, objectValue, create}
