_ = require 'lodash'
{numeric} = require './args'

module.exports = (data, options)->
  fields = numeric options
  _.pick data, fields

