_ = require 'lodash'
{numeric} = require './args'

module.exports = (data, options)->
  fields = numeric options
  if fields.length == 1
    return data[fields]

  _.pick data, fields
