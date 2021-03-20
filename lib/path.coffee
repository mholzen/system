class Path
  constructor: (path)->
    log 
    @path = path
    @position = undefined
  follow: (data)->
    for segment, i in @path
      # if typeof data != 'object'
      #   break
      # if not (segment of data)
      #   break
      if not (data?[segment]?)
        break

      @position = i
      @to = data[segment]
      if typeof @to != 'object'
        break
      data = @to
    return @reached()
  reached: ->
    @position == @path.length - 1
  remainder: ->
    @path.slice @position + 1

path = (args...)-> new Path args...

module.exports = Object.assign path, {
  Path
}
