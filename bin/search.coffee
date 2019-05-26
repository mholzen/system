#!/usr/bin/env coffee

process.env.NODE_CONFIG_DIR = __dirname + '../config'
log = require '../lib/log'
{stream} = require '../lib'
query = require '../lib/query'
searchers = require '../lib/searchers'
{json} = require '../lib/mappers'
{isStream} = require '../lib/stream'
_ = require 'lodash'

# TODO: will not output if value == undefined
replacer = (key, value)->
  if isStream value
    return undefined
  value

toJSON = json {replacer}

# silently exit if stdout is closed
process.stdout.on 'error', (event)->
  if event?.code == 'EPIPE'
    process.exit()

#
# MAIN
#
args = process.argv[2..-1]
query = query.fromArgs args

count = 0

data = searchers.all

# TODO: should be searchers.read.then
searchers.bookmarks.read.then ->

  # results = query.searchIn data
  results = query.match data

  if results == null
    console.warn "no results found"
    process.exit 1

  results = stream results
  results
  .map (match)->
    match.input = _.get data, match.path.slice 0, -1
    match

  .each (result)->
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
