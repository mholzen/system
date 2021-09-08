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
  # TODO: move to args
  applyArgs: (f, options)->
    positional = args.positional options
    if not positional?
      return (data)-> f data, options

    if positional instanceof Array
      return (data)-> f data, positional..., options

    (data)-> f data, positional, options

  notnull: (inputStream)->
    inputStream.filter (x)->x?

transformers = Object.assign transformers, requireDir './transformers'

module.exports = creator transformers