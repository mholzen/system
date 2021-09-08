isLiteral = require './isLiteral'
isValue = require './isValue'

isEdge = ([key, value])->
  not isLiteral value

edges = (data) ->
  if isValue data
    return []

  if data instanceof Array
    return Object.keys data

  if typeof data == 'object'
    return Object.entries data
    .filter isEdge
    .map ([key, value]) -> key

  throw new Error "cannot map #{data} to edges"

module.exports = Object.assign edges, {isEdge}