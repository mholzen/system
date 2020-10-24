identify = require './identify'

module.exports = (data, options)->
  name = options?.name ? identify data
  [name]: data
