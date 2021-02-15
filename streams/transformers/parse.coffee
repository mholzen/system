stream = require '../../lib/stream'
{Parser} = require '../../lib/parse'

module.exports = (options)->
  parser = options?.parser ? new Parser()

  (input)->
    input
    .split()
    .filter (line) -> line.length > 0
    .map (data)-> parser.parse data
