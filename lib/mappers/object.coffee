identify = require './identify'

name = (options)->
  if typeof options == 'string'
    return options
  options?.name ? identify data

module.exports = (data, options)->
  [name options]: data
