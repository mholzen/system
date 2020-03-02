#!/usr/bin/env coffee

map = require '../lib/map'
searchers = require '../lib/searchers'
{args} = require '../lib/mappers'
{stream} = require '../lib/'
outputter = require '../lib/outputter'

name = process.argv[2]

options = args process.argv[3..]
options.root = searchers()
options.flat = true

# TODO: generalize
if name == 'tableString'  
  options.width = process.stdout.columns

try
  mapper = map name, options
catch error
  if error instanceof RangeError
    console.error 'cannot find mapper ' + name
    console.log error.toString()
    console.log "Available mappers:\n" + Object.keys(mappers).sort().join "\n"
  else
    console.error error.stack
  process.exit()
  
stream process.stdin
.through mapper
.through outputter process.stdout, process.stderr