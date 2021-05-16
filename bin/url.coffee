#!/usr/bin/env coffee

{search} = require '../lib/'
{get, prepend, pop, content} = require '../lib/mappers'

search process.argv[2..]
.doto console.log
.map (x)->
  (get.getter 'value.0.path') x
.map get.getter 'value.0.path'
.map (x) -> prepend x, 'bookmarks'
.map pop
.map pop
.map content
.each (line)->
  process.stdout.write line + '\n'
