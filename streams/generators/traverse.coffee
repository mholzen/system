{objectEdges, objectValue} = require '../../lib/iterators/traverse'
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
  valueName = options?.valueName ? 'value'

  (data, options)->
    stream (push, next)->
      traverse = (data, path)->
        path ?= []
        # log 'start' , {data, path}
        try
          [v,edges] = await node data

          if v != null
            if not options?.noPath
              v = {[valueName]: v, path}
            push null, v
            # log 'push', {value: v}

          for edge from edges
            if edge instanceof Array
              [d,p] = edge
            else
              d = edge
              p = edge
              p = path.concat p
            # log 'edges', {data: d, path: p}
            await traverse d, p
          return
        catch e
          log 'catch', {e}
          push e, null

      await traverse data
      push null, stream.nil

  # return traverse

module.exports = Object.assign {}, {objectEdges, objectValue, create}
