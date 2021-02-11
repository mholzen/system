_ = require 'lodash'
log = require './log'
isPromise = require 'is-promise'
{isStream} = require './stream'

isNode = (data)->
  return true if ['string', 'number', 'boolean', 'function'].includes typeof data

  return true if (isStream data) or (isPromise data)

  false

edges = (data) ->
  if (not data?) or (isNode data)
    return []

  if data instanceof Array
    return Object.keys data

  Object.keys(data).filter (k) ->
    k != 'path' and
    typeof data[k] == 'object'

value = (data) ->
  if not data?
    return null
 
  if isNode data
    return data

  if typeof data == 'object'
    e = edges data
    # log.debug 'value.edges', {e}
    v  =_.pickBy data, (v,k) -> not (e.includes k) and data.hasOwnProperty k
    # log.debug {v}
    return if _.isEmpty v then null else v
  throw new Error "value not implemented for #{typeof data}"

traverse = (data, options)->
  # log.debug 'traverse.start', {data}
  options ?= {}

  v = value data

  if v != null
    if options.path
      v = {value: v, path: []}
    # log.debug 'traverse.yield', {value: v}
    yield v

  for e from edges data
    # log.debug 'traverse.edge', {e}
    for i from traverse data[e], options
      if options.path
        i.path.unshift e
      # log.debug 'traverse.yield', {value: i}
      yield i

  # WARNING: apparently, this line in needed
  # log.debug 'traverse.returning'
  return

module.exports = {
  edges
  value
  traverse
}
