_ = require 'lodash'
log = require '../log'

module.exports = (data, options)->
  sep = options[0] ? '/'
  data.join sep
