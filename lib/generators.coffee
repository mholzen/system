{stream, isStream} = require './stream'
log = require './log'
isIterable = require './mappers/isIterable'
request = require './mappers/request'
parse = require './parse'
CSON = require 'cson'
creator = require './creator'
requireDir = require 'require-dir'

#
# A generator is a function that returns an iterator, given one optional argument
#
# TODO: `traverse` is a generator and should be moved here
# TODO: should `parse` return an iterator?

keys = (x)->
  if stream.isStream x
    return x

  if typeof x == 'object'
    # this is too lose and captures objects and collections
    return stream Object.keys x

  if x instanceof Array
    return stream [0.. x.length-1]

  if typeof x == 'function'
    return stream [ x.name ]


# TODO: should this be in stream?
items = (data)->
  if isStream data
    return data

  if typeof data == 'undefined'
    return stream []

  if isIterable data
    return stream data

  if data?.items?
    return items data.items

  if data instanceof Buffer
    data = data.toString()    # TODO: optimize

  if typeof data == 'string'
    # TODO: use parser
    return stream data.split '\n'

  r = request data
  r = r
  .then (d)->
    if not d?
      log.error 'empty request'
      return []
    parse d
  .catch (e)->
    log.error e
    return []

  throw new Error "cannot get items from #{log.print data}"

lines = (data)->
  data.split '\n'
  .filter (line) -> line.length > 0

split = (data, opts)->
  sep = opts?[0] ? '\n'
  data.split '\n'

array = (data, opts)->
  Array.from data

generators = {
  keys
  items
  lines
  split
  array
  tests: require './generators/tests'
}
generators = Object.assign generators, requireDir './generators'

module.exports = creator generators