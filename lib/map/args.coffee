_ = require 'lodash'
log = require '../log'

module.exports = (opts)->
  ->
    args = Array.from _.flattenDeep arguments
    if not (args instanceof Array)
      args = [ args ]

    terms = []
    for arg in args
      if typeof arg == 'string'
        [key, value] = arg.split ':'
      else
        throw new Error "typeof arg #{typeof arg} is not a string"

      if not value?
        terms.push key
      else
        arg = {}
        arg[key] = value
        terms.push arg

    terms
