_ = require 'lodash'
log = require '../log'
{parseValue, parsePath} = require '../parse'
isLiteral = require './isLiteral'
isArray = require './isArray'

term = (data)->
  # log {data}

  i = data.lastIndexOf ':'
  if i == -1
    # data is a value or a path
    return parsePath parseValue data
  
  key = data.slice 0, i
  value = parseValue data.slice i+1

  if key.length == 0
    return {0: value}

  keys = key.split /[\.:]/
  res = value
  while key = keys.pop()
    r = {[key]: res}
    res = r
  return res

class Arguments
  @from: (words)->
    # log {words}
    new Arguments words

  constructor: (data)->
    @positional = []
    @options = {}

    if typeof data == 'string'
      data = data.split ','

    if not (Array.isArray data)
      if typeof data == 'object'
        @options = data
        return

      throw new Error "expecting array, got #{data}"

    for arg, i in data
      if typeof arg == 'object'
        Object.assign @options, arg
        continue

      if typeof arg != 'string'
        @positional.push arg
        continue

      t = term arg
      if isLiteral(t) or isArray(t)
        @positional.push t
      else
        Object.assign @options, t

  first: ->
    @positional[0]

  all: ->
    all = Array.from @positional
    if Object.keys(@options).length > 0
      all.push @options
    all

class OneOf
  constructor: (array)->
    @array = array
  helper: ->
    "One of: #{@array.join ', '}"
  test: (data)->
    data in @array

class Signature
  @from: (data)->
    if Array.isArray data
      return new OneOf data

Arguments.Signature = Signature

args = (x)-> Arguments.from x

module.exports = Object.assign args, {Arguments, term}