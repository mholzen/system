_ = require 'lodash'

edges = (data) ->
  if data instanceof Array
    return Object.keys data
  if data == null
    return []
  Object.keys(data).filter (k) -> typeof data[k] == 'object'

value = (data) ->
  if ['string', 'number', 'function'].includes typeof data
    return data
  if typeof data == 'object'
    e = edges data
    v  =_.pickBy data, (v,k) -> not e.includes k
    return if _.isEmpty v then null else v
  throw new Error "value not implemented for #{typeof data}"

traverse = (data, options)->
  options ?= {}
  v = value data
  if v != null
    if options.path
      v = {value: v, path: []}
    yield v

  for e from edges data
    for i from traverse data[e], options
      if options.path
        i.path.unshift e
      yield i

module.exports = {
  edges
  value
  traverse
}
