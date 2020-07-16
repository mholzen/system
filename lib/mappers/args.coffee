_ = require 'lodash'
log = require '../log'
{parseValue} = require '../parse'

args = (data)->
  if not (data instanceof Array)
    throw new Error "expecting array"

  result = {}
  for arg, i in data
    if typeof arg != 'string'
      result[i] = arg
      continue

    elements = arg.split ':'

    if elements.length == 1
      elements.unshift i

    if elements[0].length == 0
      elements[0] = i
      if elements[1].length == 0
        elements[1] = ':'

    _.set result, elements[..-2], parseValue elements[elements.length-1]

  result

args.positional = (data)->
  if typeof data == 'string'
    return [data]
  r = []
  for k, v of data
    if not isNaN (i = parseInt k)
      r[i] = v
  if r.length == 0
    return null
  r.filter (x)->x?

module.exports = args
