_ = require 'lodash'
log = require '../log'

value = require './value'
identify = require './identify'

augment = (data, addition, options)->
  log {addition, options}
  addition = value data, addition, options

  name = if typeof options?.name == 'string'
    options.name
  else
    identify addition

  if typeof data != 'object'
    data = [identify data]: data

  Object.assign data, [name]: addition

module.exports = Object.assign augment
