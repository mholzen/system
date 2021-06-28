isNumber = require './isNumber'

getCount = (data)->
  if data?.count?
    return data.count
  if isNumber data
    return data
  2

module.exports = (data, options)->
  count = getCount options
  Array(count).fill data