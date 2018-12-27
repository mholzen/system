stream = require 'highland'
log = require '@vonholzen/log'
dates = require './dates'

keys = (x)->
  if stream.isStream x
    return x

  if typeof x == 'object'    # this is too lose and captures objects and collections
    return stream Object.keys x

  if x instanceof Array
    return stream [0.. x.length-1]

  if typeof x == 'function'
    return stream [ x.name ]

module.exports = {
  keys
  dates
}
