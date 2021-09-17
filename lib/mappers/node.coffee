isValue = require './isValue'
edges = require './edges'
invert = require './invert'

###

is `value` defined in relation to `edges`, vice versa, or based another function (`node`? or simpler?)

###
value = (data)->
  # log 'value', {data}
  if isValue data
    # log 'value returning data'
    return data

  # log 'value not returning data'

  if data instanceof Array
    return null

  if typeof data == 'object'
    return Object.entries data
    .filter invert edges.isEdge
    .reduce (memo, [key, value])->
      Object.assign memo, {[key]: value}
    , {}

  throw new Error "cannot determine value from #{log.print data}"

node = (data)->
  # where
  #   data is a node or a node identifier
  # returns {value, edges}
  #   where `edges` is an array of [edge] ?

  return
    value: value data
    edges: edges data

module.exports = Object.assign node, {
  isValue
}