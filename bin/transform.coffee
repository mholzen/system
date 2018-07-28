#!/usr/bin/env coffee
highland = require 'highland'

table = (stream)->
  table = new Table()
  stream.parse()
  .doto (item)->
    row = table.add item
    if table.header
      return row
    else
      # do not push an item

transforms =
  table: null

highland(process.stdin)
.pipe transforms.table
.each (item)->
  if typeof item == 'object'
    item = JSON.stringify item
  process.stdout.write item + '\n'
