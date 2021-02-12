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

try
  mapper = mappers name, options
catch e
  console.error "Name'#{name}' not found"
  console.error "help: " + mappers.signature?.helper()
  process.exit 1

if not mapper?
  console.error "cannot find mapper '#{name}'"
  console.log "Available mappers:\n" + Object.keys(mappers).sort().join "\n"
  process.exit 1

stream process.stdin
.through parse()
.through map mapper, options
.errors (err)->
  console.log err
  process.exit 1
  # TODO: any errors in outputter will not set the process exit code
.through outputter process.stdout, process.stderr
