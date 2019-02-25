{stream, isStream} = require './stream'
log = require '@vonholzen/log'
dates = require './dates'
iterable = require './map/iterable'
request = require './request'
parse = require './parse'

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

  if iterable data
    return stream data

  if data?.items?
    return items data.items

  if data instanceof Buffer
    data = data.toString()    # TODO: optimize

  if typeof data == 'string'
    # TODO: use parser
    return stream data.split '\n'

  r = request data
  if r?
    return parse r

  throw new Error "cannot get items from #{log.toPrettyString data}"

module.exports = {
  keys
  dates
  items
}
