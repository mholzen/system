#!/usr/bin/env coffee

process.env.NODE_CONFIG_DIR = __dirname + '../config'

{fromArgs} = require '../lib/query'
log = require '@vonholzen/log'

args = process.argv[2..-1]
query = fromArgs args

process.stdout.on 'error', (event)->
  if event?.code == 'EPIPE'
    # silently exit if stdout is closed
    process.exit()

count = 0
# searcher = require '../searcher'
# results = searcher.search query, query.options

# NEW
results = query.searchIn()

results.each (result)->
  if not ('toString' in result)
    result.toString = ()-> JSON.stringify result

  process.stdout.write result.toString() + '\n'

  count++
  if query.options.limit? and count >= query.options.limit
    process.exit()

if query.options.duration?
  setTimeout ->
    process.exit()
  , query.options.duration
