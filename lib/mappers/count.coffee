isLiteral = require './isLiteral'

module.exports = (data)->
  if data?.length?
    return data.length
  
  if isLiteral data
    return 1

  if not data?
    return 0