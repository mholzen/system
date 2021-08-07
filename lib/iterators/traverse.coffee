log = require '../log'
isLiteral = require '../mappers/isLiteral'
isStream = require '../mappers/isStream'
isPromise = require '../mappers/isPromise'
_ = require 'lodash'

isValue = (data)->
  return true if isLiteral data
  return true if typeof data == 'function'
  return true if (isStream data) or (isPromise data)
  false

class Edge
  constructor: (edge, target)->
    @edge = edge
    @target = target

objectEdges = (data) ->
  if (not data?) or (isValue data)
    return []

  if data instanceof Array
    # TODO: return an object rather than an array
    return Object.keys(data).map (k)->[data[k], k]

  Object.keys data
  .filter (k) ->
    k != 'path' and
    typeof data[k] == 'object'
  .map (k)->
    # TODO: return an object rather than an array
    [data[k], k]

objectValue = (data) ->
  if not data?
    return null
 
  if isValue data
    return data

  if typeof data == 'object'
    e = objectEdges data
    e = e.map (x)->x[1]   # get paths only
    v  =_.pickBy data, (v,k) -> not (e.includes k) and data.hasOwnProperty k
    # log 'objectValue', {value: v, edges: e}
    return if _.isEmpty v then null else v
  throw new Error "value not implemented for #{typeof data}"

create = (options)->
  # log 'traverse', {options}
  value = options?.value ? objectValue
  edges = options?.edges ? objectEdges

  traverse = (data)->
    # log.debug 'traverse.start', {data}
    v = value data

    if v != null
      if not options?.noPath
        v = {value: v, path: []}
      # log.debug 'traverse.yield', {value: v}
      yield v

    # log {edges: edges data}
    for edge from edges data
      # log.debug 'traverse.edge', {edge}
      [d,e] = edge
      for i from traverse d, options
        if not options?.noPath
          i.path.unshift e
        # log.debug 'traverse.yield', {value: i}
        yield i

    # WARNING: apparently, this line in needed
    # log.debug 'traverse.returning'
    return

  return traverse

module.exports = Object.assign create(), {objectEdges, objectValue, create}
