parse = require '../lib/parse'
stream = require './stream'
outputter = require '../lib/outputter'

log = require './log'
mappers = require '../lib/mappers'
args = mappers.args

# {fromArgs} = require './query'
resolve = require '../lib/resolve'

map = (mapper, options)->
  positional = null
  if typeof mapper == 'string'
    if not (mapper of mappers)
      throw new RangeError "mapper '#{mapper}' not found"
    mapper = mappers[mapper]
    positional = args.positional options

  parser = new parse.Parser()

  (inputStream)->
    inputStream
    .split()
    .filter (line) -> line.length > 0
    .map (item)-> parser.parse item
    .map (item)->
      log.debug {item}
      if not positional?
        return mapper item, options
      if positional instanceof Array
        return mapper item, positional..., options
      mapper item, positional, options
    .map (x)->
      if options?.flat and stream.isStream x
        return x
      stream resolve.deep x
    .parallel 10

module.exports = map
