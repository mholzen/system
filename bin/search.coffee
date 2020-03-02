#!/usr/bin/env coffee

process.env.NODE_CONFIG_DIR = __dirname + '../config'

search = require '../lib/search'
outputter = require '../lib/outputter'

# silently exit if stdout is closed
process.stdout.on 'error', (event)->
  if event?.code == 'EPIPE'
    process.exit()

#
# MAIN
#
args = process.argv[2..-1]
search args
.through outputter process.stdout, process.stderr

# TODO
# if query.options.duration?
#   setTimeout ->
#     process.exit()
#   , query.options.duration
#

# if results == null
#   console.warn "no results found"
#   process.exit 1

# count = 0
#   count++
#   if query.options.limit? and count >= query.options.limit
#     process.exit()
