isLiteral = require './isLiteral'
parse = require 'csv-parse/lib/sync'

module.exports = (data, options)->
  if typeof data == 'string'
    # parse CSV
    return (parse data)[0]

  # NOTE: idempotent side effect
  if typeof options?.res?.type == 'function'
    options.res.type 'text/plain'

  if isLiteral data
    return [ data ]
  if data instanceof Array
    return data
  if data?.path?
    return data.path
