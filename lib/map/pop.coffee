getArray = require './array'

module.exports = (data, options)->
  array = getArray data
  if not array?
    throw new Error 'cannot determine array'

  array.pop()
  data
