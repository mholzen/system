#!/usr/bin/env coffee

process.env.NODE_CONFIG_DIR = __dirname + '../config'

{fromArgs} = require '../lib/query'

args = process.argv[2..-1]
query = fromArgs args

parse = require 'transform/parse'
{string} = require 'transform/mappers'

toString = string()

parse process.stdin
.filter (item)-> query.match item
.each (item)->
  process.stdout.write toString(item) + '\n'
