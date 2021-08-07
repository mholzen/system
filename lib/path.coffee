log = require './log'

class Path
  constructor: (path, data)->
    if typeof path == 'string'
      path = path.split '.'

    @path = path
    @position = undefined
    @_follow data

  _follow: (data)->
    # log {path: @path, data}
    for segment, i in @path
      if not (data?[segment]?)
        break
      # log "found segment in data.", {segment, data}
      @position = i
      @to = data[segment]
      if typeof @to != 'object'
        return @to
      data = @to
    @

  reached: ->
    @position == @path.length - 1

  remainder: ->
    @path.slice @position + 1

path = (args...)-> new Path args...

module.exports = Object.assign path, {
  Path
}
