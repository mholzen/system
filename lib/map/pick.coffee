_ = require 'lodash'

module.exports = (data, fields)->
  if fields instanceof Array
    _.pick data, fields
  else
    data[fields]
