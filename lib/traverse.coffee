_ = require 'lodash'
log = require './log'
isPromise = require 'is-promise'
{isStream} = require './stream'

isNode = (data)->
  return true if ['string', 'number', 'function'].includes typeof data

  return true if (isStream data) or (isPromise data)

  false

edges = (data) ->
  if (data == null) or (isNode data)
    return []

  if data instanceof Array
    return Object.keys data

  Object.keys(data).filter (k) ->
    k != 'path' and
    typeof data[k] == 'object'

value = (data) ->
  if isNode data
    return data

  if typeof data == 'object'
    e = edges data
    log.debug 'value.edges', {e}
    v  =_.pickBy data, (v,k) -> not e.includes k
    return if _.isEmpty v then null else v
  throw new Error "value not implemented for #{typeof data}"

traverse = (data, options)->
  log.debug 'traverse.start', {data}
  options ?= {}

  v = value data

  if v != null
    if options.path
      v = {value: v, path: []}
    log.debug 'traverse.yield', {value: v}
    yield v

  for e from edges data
    log.debug 'edge', {e}
    for i from traverse data[e], options
      if options.path
        i.path.unshift e
      log.debug 'traverse.yield', {value: i}
      yield i

  # why the fuck is this needed?
  log.debug 'returning'

module.exports = {
  edges
  value
  traverse
}
