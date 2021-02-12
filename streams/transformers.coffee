creator = require '../lib/creator'
requireDir = require 'require-dir'

{Parser} = require '../lib/parse'
{stream, isStream} = require '../lib/stream'
outputter = require '../lib/outputter'
mappers = require '../lib/mappers'
resolve = require '../lib/resolve'
log = require '../lib/log'
args = mappers.args
creator = require '../lib/creator'

#
# transformers are generators that take 1 argument
#
transformers =
  parse: (parser)->
    parser ?= new Parser()
    (inputStream)->
      inputStream
      .split()
      .filter (line) -> line.length > 0
      .map (data)-> parser.parse data

  # TODO: move to args
  applyArgs: (f, options)->
    positional = args.positional options
    if not positional?
      return (data)-> f data, options

    if positional instanceof Array
      return (data)-> f data, positional..., options

    (data)-> f data, positional, options

  map: (mapper, options)->
    (inputStream)->
      inputStream
      .map mapper
      .map (x)->
        if options?.flat and isStream x
          return x

        # this probably lives in outputter
        stream resolve.deep x
      .parallel 10

  notnull: (inputStream)->
    inputStream.filter (x)->x?

  head: (inputStream, options)->
    n = options?.n ? 10
    inputStream.take n

  filter: (inputStream, name, options)->
    filters =
      ok: (x)->x?
      string: (x)->
        if options?.path?
          x = _.get x, options.path
        typeof x == 'string'

    f = filters[name] ? filters.ok
    # log.debug 'filter', {name}
    inputStream.filter f

transformers = Object.assign transformers, requireDir './transformers'

module.exports = creator transformers