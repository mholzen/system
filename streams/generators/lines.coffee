isReadable = require '../../lib/mappers/isReadable'
string = require '../../lib/mappers/string'
stream = require '../../lib/stream'

streamOrString = (data)->
  if isReadable data
    return stream data
  string data

module.exports = (data)->
  # log.debug 'lines', {data}

  data = streamOrString data

  data.split '\n'
  .filter (line) -> line.length > 0
