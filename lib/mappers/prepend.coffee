_ = require 'lodash'
getArray = require './array'
value = require './value'

module.exports = (data, addition, options)->
  addition = value data, addition, options

  if not addition?
    throw new Error 'nothing to prepend with'

  if typeof data == 'string'
    return addition + data

  array = getArray data
  if not array?
    throw new Error 'cannot determine array'

  array.unshift addition
  array
