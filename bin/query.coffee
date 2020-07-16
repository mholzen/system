#!/usr/bin/env coffee

process.env.NODE_CONFIG_DIR = __dirname + '../config'

{fromArgs} = require '../lib/query'
parse = require '../lib/parse'
string = require '../lib/mappers/string'

args = process.argv[2..-1]
query = fromArgs args

toString = string()

parse process.stdin
.filter (item)-> query.match item
.each (item)->
  process.stdout.write toString(item) + '\n'
