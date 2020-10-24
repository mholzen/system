log = require '../log'
_ = require 'lodash'

module.exports = (data, value, options)->
  if typeof value == 'function'
    return value data

  if typeof value == 'string' and _.get options, value
    return _.get options, value

  if typeof options?.resolve == 'function'
    return (options.resolve value, options) data

  value
