log = require '../log'
_ = require 'lodash'

module.exports = (data, value, options)->
  if typeof value == 'function'
    return value data, options

  if typeof value == 'string'
    r = _.get options, value
    log.debug 'options?', {r, value, resolve: options?.resolve}
    if typeof r == 'function'
      return r data, options
    if r?
      return r

  if typeof options?.resolve == 'function'
    resolve = options?.resolve value, options
    log.debug 'value', {resolve, value}
    return resolve data

  value
