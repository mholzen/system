_ = require 'lodash'
{numeric} = require './args'

module.exports = (data, paths)->
  # fields = numeric options
  _.pick data, paths
