{stream, isStream} = require './stream'
log = require '@vonholzen/log'
dates = require './dates'
isIterable = require './map/isIterable'
request = require './request'
parse = require './parse'
{edges, value, traverse} = require './generators/traverse'

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

  throw new Error "cannot get items from #{log.toPrettyString data}"

module.exports = {
  keys
  dates
  items
  edges
  value
  traverse
}
