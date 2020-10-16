_ = require 'lodash'
log = require '../log'

module.exports = (data, paths...)->
  _.pick data, paths
