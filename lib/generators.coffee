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

items = (data)->
  if typeof data == 'undefined'
    return stream []

  if isStream data
    return data

  if typeof data == 'object' and isStream data.items
    return data.items

  if data instanceof Buffer
    data = data.toString()    # TODO: optimize

  if typeof data == 'string'
    # TODO: use parser
    return stream data.split '\n'

  if typeof data[Symbol.iterator] == 'function'
    return stream data

  throw new Error "cannot get items from #{data}"

module.exports = {
  keys
  dates
  items
}
