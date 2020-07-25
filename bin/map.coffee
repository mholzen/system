#!/usr/bin/env coffee

mappers = require '../lib/mappers'
searchers = require '../lib/searchers'
{args} = require '../lib/mappers'
{stream} = require '../lib/'
{parse, map} = require '../streams/transformers'
outputter = require '../lib/outputter'

name = process.argv[2]

options = args process.argv[3..]
options.root = searchers()
options.flat = true

# TODO: generalize
if name == 'tableString'  
  options.width = process.stdout.columns

if typeof mappers[name] != 'function'
  console.error "cannot find mapper '#{name}"
  console.log "Available mappers:\n" + Object.keys(mappers).sort().join "\n"
  process.exit()

mapper = mappers[name]

stream process.stdin
.through parse()
.through map mapper, options
.through outputter process.stdout, process.stderr