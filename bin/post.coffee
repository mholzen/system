#!/usr/bin/env coffee
log = require '@vonholzen/log'

resource = process.argv[2]

{post} = require '../lib'

# read content from stdin
content = process.stdin
output = ->
  post(content, resource)

try
  output().then (resource)->
    process.stdout.write resource.toString() + '\n'
catch error
  process.stderr.write error.toString()
