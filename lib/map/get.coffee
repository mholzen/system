_ = require 'lodash'
{numeric} = require './args'

module.exports = (data, options)->
  fields = numeric options
  if not (fields?.length >= 1)
    throw new Error 'get: at least one argument required'
  _.get data, fields[0], fields[1]

