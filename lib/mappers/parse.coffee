

csvParse = require 'csv-parse/lib/sync'


module.exports = (data, options)->
  if data instanceof Buffer
    data = data.toString()

  if typeof data == 'string'
    if ['[', '{'].includes data?[0]
      return JSON.parse data
    
    # if 0 < data.indexOf ','
    #   rows = csvParse data, columns: null
    #   return rows

  if options?.req?.filename?.endsWith '.cson'
    # TODO: require 'cson-parser', which requires coffeescript 1.2.7
    # introduces a bug with line numbers in stack traces
    # csonParser = require 'cson-parser/lib/parse'
    # return CSON.parse data

    throw new Error "cannot parse cson because of stacktrace bug"

  throw new Error "cannot parse data of type #{typeof data}  '#{log.print {data}}'"