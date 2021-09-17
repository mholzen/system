# TODO: should be a reducer

{NotFound, NotProvided, NotMapped, NotSpecific} = require './errors'

class Path
  constructor: (path, data)->
    if typeof path == 'string'
      path = path.split '.'
      .map (x)-> if x.length == 0 then undefined else x   # convert '' to undefined

    @path = path
    @data = data
    @position = undefined
    @to = undefined
    @_follow()

  _follow: ->
    # log {path: @path, data: @data}
    @to = @data
    for segment, i in @path
      if typeof segment == 'undefined'
        @to = @data
        continue
      if not (@to?[segment]?)
        break
      # log "found segment in @data.", {segment, data: @data}
      @position = i
      @to = @to[segment]
      if typeof @to != 'object'
        return @to
    @

  _get: ->
    if not @reached()
      throw new NotFound @path, @data

    if @remainder().length > 0
      throw new Error "path #{log.print @path} is not specific enough (remainder: '#{log.print @remainder()}', root: '#{log.print @data}')"
      # throw new NotSpecific @path, 'defined', @to

    if typeof @to == 'function'
      return @to

    if typeof @to.create == 'function'
      return @to

    throw new NotSpecific @data, '?', @to     # TODO: specific to the use case


  reached: ->
    @position == @path.length - 1

  remainder: ->   # TODO: why a function?
    @path.slice @position + 1

path = (args...)-> new Path args...

module.exports = Object.assign path, {
  Path
}
