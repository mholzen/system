getArray = require './array'

module.exports = (data, prefix, options)->
  if not prefix?
    throw new Error 'nothing to prepend with'

  array = getArray data
  if not array?
    throw new Error 'cannot determine array'

  array.unshift prefix
  data
