isLiteral = require './isLiteral'

module.exports = (data)->
  if isLiteral data
    return [ data ]
  if data instanceof Array
    return data
  if data?.path?
    return data.path
