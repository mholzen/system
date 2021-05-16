log = require '../log'
table = require '../table'

parse = require './parse'
# parse = require 'csv-parse'
# parse = require 'csv-parse/lib/sync'

module.exports = (data, options)->
  if data instanceof Buffer
    data = data.toString()

  if typeof data == 'string'

    return table parse data, {columns: true, skip_empty_lines: true}

  if Array.isArray data
    return table data, options

  throw new Error "can't create table from #{typeof data}"