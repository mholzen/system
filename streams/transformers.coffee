{Parser} = require '../lib/parse'
{stream, isStream} = require '../lib/stream'
outputter = require '../lib/outputter'
mappers = require '../lib/mappers'
resolve = require '../lib/resolve'
log = require '../lib/log'
args = mappers.args

#
# transformers are generators that take 1 argument
#

parse = (parser)->
  parser ?= new Parser()
  (inputStream)->
    inputStream
    .split()
    .filter (line) -> line.length > 0
    .map (data)-> parser.parse data

# TODO: move to args
applyArgs = (f, options)->
  positional = args.positional options
  if not positional?
    return (data)-> f data, options

  if positional instanceof Array
    return (data)-> f data, positional..., options
  
  (data)-> f data, positional, options

map = (mapper, options)->
  positional = args.positional options
  mapper = applyArgs mapper, options
  (inputStream)->
    inputStream
    .map mapper
    .map (x)->
      if options?.flat and isStream x
        return x
      stream resolve.deep x
    .parallel 10

module.exports = {parse, map}