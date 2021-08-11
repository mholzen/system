{NotFound, NotProvided, NotMapped, NotSpecific} = require './errors'

class Path
  constructor: (path, data)->
    if typeof path == 'string'
      path = path.split '.'

    @path = path
    @data = data
    @position = undefined
    @_follow()

  _follow: ->
    # log {path: @path, data: @data}
    for segment, i in @path
      if not (@data?[segment]?)
        break
      # log "found segment in @data.", {segment, data: @data}
      @position = i
      @to = @data[segment]
      if typeof @to != 'object'
        return @to
      @data = @to
    @

  _get: ->
    if not @to?
      throw new NotFound @path, @data

    if @remainder().length > 0
      throw new NotSpecific @data, '?', @to

    if typeof @to == 'function'
      return @to

    if typeof @to.create == 'function'
      return @to

    throw new NotSpecific @data, '?', @to     # TODO: specific to the use case


  reached: ->
    @position == @path.length - 1

  remainder: ->
    @path.slice @position + 1

path = (args...)-> new Path args...

module.exports = Object.assign path, {
  Path
}
