{stream, isStream} = require './stream'
log = require '@vonholzen/log'
dates = require './dates'

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

  throw new Error "cannot get items from #{data}"

module.exports = {
  keys
  dates
  items
}
