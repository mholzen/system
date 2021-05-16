isLiteral = require './isLiteral'

module.exports = (data, options)->
  if typeof data == 'string'
    return (data.match /,/g || []).length

  if data?.length?
    return data.length

  if isLiteral data
    return 1

  if not data?
    return 0