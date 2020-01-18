_ = require 'lodash'
log = require './log'
{Match} = require './match'
isPromise = require 'is-promise'

class Results
  constructor: (data)->
    if isPromise data
      @values = data
      return

    if not (data instanceof Array)
      throw new Error "expecting Array"

    log 'Results.constructor', {data}
    @values = new Map data


  size: -> @values.size

  prepend: (path)->
    if isPromise @values
      @values = new Map [[ path, @values ]]
      return @

    if not (path instanceof Array)
      p = Array.from path
      if p.length == 0
        throw new Error "could not make array out of path #{path}"
      path = p

    log 'prepending', {v: @values, path}
    @values.forEach (value, key)->
      path.reduceRight (m, element)->
        key.unshift element
      , null

    log 'prepended', {v: @values}
    @

  toArray: ->
    if isPromise @values
      return [ @values ]

    Array.from @values, ([key, value]) -> new Match value, key

  toJSON: ->
    @toArray()


module.exports = {
  Results
}
