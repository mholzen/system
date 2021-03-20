_ = require 'lodash'
log = require '../log'
{parseValue} = require '../parse'

class Arguments
  @from: (words)->
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
        @options = Object.assign @options, arg
        continue

      if typeof arg != 'string'
        @positional.push arg
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

      if typeof path[0] == 'number'
        @positional.push value
      else
        _.set @options, path, value

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

module.exports = Object.assign args, {Arguments}