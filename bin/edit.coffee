#!/usr/bin/env coffee
log = require '@vonholzen/log'

parse = require '../parse'

{spawn} = require 'child_process'

if not process.stdin.isTTY
  values = parse(process.stdin)

values.each (value)->
  spawn 'edit', [ value.path ]
