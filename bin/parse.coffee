#!/usr/bin/env coffee
highland = require 'highland'
{parse} = require '../index.coffee'
content = require '../content'
log = require '@vonholzen/log'

name = process.argv[2]

highland(process.stdin)
.split()
.filter (line) -> line.length > 0
.map parse
.each (item)->

  if name == 'content'
    item = await content(item)

    parse(item).map (subitem)->
      value =
        content: subitem
        source: item

      if typeof value == 'object'
        value = JSON.stringify value
      process.stdout.write value + '\n'
    return

  if typeof item == 'object'
    item = JSON.stringify item
  process.stdout.write item + '\n'
