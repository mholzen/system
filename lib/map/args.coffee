_ = require 'lodash'
log = require '../log'
{parseValue} = require '../parse'


module.exports = ->
  (data)->
    if not (data instanceof Array)
      throw new Error "expecting array"

    result = {}
    for arg, i in data
      if typeof arg != 'string'
        result[i] = arg
        continue

      [key, value] = arg.split ':'

      if not value?
        value = key
        key = i

      result[key] = parseValue value

    result
