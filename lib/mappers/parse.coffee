count = require './count'
isProperty = require './isProperty'
# {isStream} = require './stream'
csvParse = require 'csv-parse/lib/sync'

line = (data)->
  data.slice 0, data.indexOf "\n"

lines = (data)->
  data.split "\n"

lines.detect = (data)->
  if 0 < data.indexOf "\n"
    return true

parse = (data, options)->
  if data instanceof Buffer
    data = data.toString()

  if data instanceof Array
    return data

  if typeof data == 'string'
    if options?.req?.filename?.endsWith '.cson'
      # TODO: require 'cson-parser', which requires coffeescript 1.2.7
      # introduces a bug with line numbers in stack traces
      csonParser = require 'cson-parser/lib/parse'
      return csonParser data

    if ['[', '{'].includes data?[0]
      return JSON.parse data
    
    if line(data)?.length >= 1    # data has 
      hasColumns = isProperty data
      try
        rows = csvParse data, {columns: if hasColumns then true else null }
      catch e
        e.data = data
        e.options = options
        log.error 'parse', {e}
        throw e
      return rows

    if lines.detect data
      return lines data

    throw new Error "cannot parse cson because of stacktrace bug"


  # TODO: Creates circular reference
  # if isStream data
  #   data.through parse

  throw new Error "don't know how to parse #{typeof data} '#{log.print data}'"

module.exports = parse
