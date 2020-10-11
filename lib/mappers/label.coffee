isLiteral = require './isLiteral'

module.exports = (data)->
  if isLiteral data
    return label: data

