#!/usr/bin/env coffee

process.env.NODE_CONFIG_DIR = __dirname + '../config'

query = require '../lib/query'
searchers = require '../lib/searchers'
log = require '@vonholzen/log'
{json} = require '../lib/mappers'

args = process.argv[2..-1]
query = query.fromArgs args

# silently exit if stdout is closed
process.stdout.on 'error', (event)->
  if event?.code == 'EPIPE'
    process.exit()

count = 0

results = query.searchIn searchers

toJSON = json()
results.each (result)->
  if not ('toString' in result)
    result.toString = ()-> toJSON result

  process.stdout.write result.toString() + '\n'

  count++
  if query.options.limit? and count >= query.options.limit
    process.exit()

if query.options.duration?
  setTimeout ->
    process.exit()
  , query.options.duration
