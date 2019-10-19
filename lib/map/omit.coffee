_ = require 'lodash'

module.exports = (data, fields)->
  if not (fields instanceof Array)
    fields = [fields]

  _.omit data, fields
