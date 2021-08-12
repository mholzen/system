isLiteral = require './isLiteral'
parse = require 'csv-parse/lib/sync'

module.exports = (data, options)->
  if data instanceof Array
    return data

  if typeof data == 'string'
    # parse CSV
    return (parse data)[0]

  if typeof data == 'number'
    return Array(data)

  # NOTE: idempotent side effect
  if typeof options?.res?.type == 'function'
    options.res.type 'text/plain'
