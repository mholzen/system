_ = require 'lodash'

module.exports = (fields)->
  (data)->
    if not (fields instanceof Array)
      fields = [fields]

    _.omit data, fields
