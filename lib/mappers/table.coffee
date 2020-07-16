log = require '../log'
table = require '../table'

# parse = require 'csv-parse'
parse = require 'csv-parse/lib/sync'

module.exports = (data, options)->
  if data instanceof Buffer
    data = data.toString()

  if typeof data == 'string'
    return table parse data, {columns: true, skip_empty_lines: true}
  return data
    
