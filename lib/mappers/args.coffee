_ = require 'lodash'
log = require '../log'
{parseValue} = require '../parse'

args = (data)->
  if typeof data == 'string'
    data = data.split ','

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

    path = elements[..-2]
    value = parseValue elements[elements.length-1]
    # log.debug 'args adding', {path, value}
    _.set result, path, value

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

args.positionalWithOptions = (words)->
  options = args words
  positional = args.positional words
  if not positional?
    return [ options ]

  if positional instanceof Array
    return [ positional..., options ]

  return [ positional, options ]

class Arguments   # TODO: consider extending Array
  @from: (words)-> new Arguments words

  constructor: (words)->
    @v = args words

  toArray: ->
    result = []
    options = {}
    for k, v of @v
      if isNaN (i = parseInt k)
        options[k] = v
      else
        result[i] = v
    result.push options
    result.filter (x)->x?

  options: ->
    @toArray().last()

  positional: ->
    @toArray().slice 0, -1

module.exports = Object.assign args, {Arguments}