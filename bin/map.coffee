#!/usr/bin/env coffee
highland = require 'highland'
log = require '@vonholzen/log'
parse = require '../lib/parse'
Promise = require 'bluebird'
isPromise = require 'is-promise'
mappers = require '../lib/mappers'

name = process.argv[2]

mapper = mappers[name]
# TODO: use factory

if not mapper?
  console.error 'cannot find mapper ' + name
  console.log "Available mappers:\n" + Object.keys(mappers).sort().join "\n"
  process.exit()

options = process.argv[3..] ? {}
if name == 'tableString'
  options.width = process.stdout.columns

log 'options', {options}
map = mapper options

parser = new parse.Parser()

highland(process.stdin)
.split()
.filter (line) -> line.length > 0
.map (item)-> parser.parse item
.map map
.map (item)->
  if not isPromise item
    item = Promise.resolve item
  highland(item)
.parallel 10
.each (item)->
  if typeof item == 'object'
    item = JSON.stringify item
  process.stdout.write item + '\n'
