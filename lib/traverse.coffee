_ = require 'lodash'
log = require './log'
isPromise = require 'is-promise'
{isStream} = require './stream'

isNode = (data)->
  return true if ['string', 'number', 'boolean', 'function'].includes typeof data
  return true if (isStream data) or (isPromise data)
  false

objectEdges = (data) ->
  if (not data?) or (isNode data)
    return []

  if data instanceof Array
    return Object.keys data

  Object.keys data
  .filter (k) ->
    k != 'path' and
    typeof data[k] == 'object'

objectValue = (data) ->
  if not data?
    return null
 
  if isNode data
    return data

  if typeof data == 'object'
    e = objectEdges data
    # log.debug 'value.edges', {e}
    v  =_.pickBy data, (v,k) -> not (e.includes k) and data.hasOwnProperty k
    # log.debug {v}
    return if _.isEmpty v then null else v
  throw new Error "value not implemented for #{typeof data}"

create = (options)->
  # log.debug 'traverse', {options}
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

    for e from edges data
      # log.debug 'traverse.edge', {e}
      for i from traverse data[e], options
        if not options?.noPath
          i.path.unshift e
        # log.debug 'traverse.yield', {value: i}
        yield i

    # WARNING: apparently, this line in needed
    # log.debug 'traverse.returning'
    return

  return traverse

module.exports = Object.assign create(), {objectEdges, objectValue, create}
