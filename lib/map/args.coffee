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

    [key, value] = arg.split ':'

    if not value?
      value = key
      key = i

    if key.length == 0
      key = i
      if value.length == 0
        value = ':'

    result[key] = parseValue value

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
  r.sort()

module.exports = args
