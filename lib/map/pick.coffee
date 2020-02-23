_ = require 'lodash'

module.exports = (data, paths)->
  _.pick data, paths
