#!/usr/bin/env coffee
log = require '@vonholzen/log'
parse = require '../parse'
content = require '../content'

values = parse(process.stdin)

toTTY = (item)->
  if typeof item == 'object'
    if item.content?
      item = item.content
    else if item.path?
      item = item.path
    else if item.url?
      item = item.url
    else
      item = JSON.stringify item
    return item


values.each (item)->
  if process.stdout.isTTY
    item = toTTY item
  else
    if ('toString' in item)
      item = item.toString()
    else
      item = JSON.stringify item

  process.stdout.write item + '\n'

  #
  #   value = content(value)
  #
  # if not ('toString' in value)
  #   value.toString = ()-> JSON.stringify value
  #
  # process.stdout.write value.toString() + '\n'
