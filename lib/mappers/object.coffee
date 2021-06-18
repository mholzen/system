identify = require './identify'

name = (data, options)->
  if typeof options == 'string'
    return options
  options?.name ? identify data

module.exports = (data, options)->
  [name data, options]: data
