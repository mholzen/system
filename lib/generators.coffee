stream = require 'highland'
log = require '@vonholzen/log'

keys = (x)->
  if typeof x == 'object'    # this is too lose and captures objects and collections
    stream Object.keys x

module.exports = {
  keys
}
