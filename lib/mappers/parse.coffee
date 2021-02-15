CSON = require 'cson-parser'
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
    return CSON.parse data

  throw new Error "cannot parse data of type #{typeof data}  '#{log.print {data}}'"