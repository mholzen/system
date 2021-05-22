class NotProvided extends Error
  constructor: (name)->
    super "'#{name}' is required but undefined"
    @name = name

class NotFound extends Error
  constructor: (key, sets...)->
  # TODO: nice to have: names for sets
    if typeof key == 'undefined'
      super "Cannot find without a key"
    else
      super "Cannot find '#{key}'"
    @key = key
    @sets = sets.map (set)->
      if not (set instanceof Array)
        set = Object.keys set
      set.sort()

  toString: ->
    @message + " in #{@sets.length} set(s)"

  send: (res)->
    res.status 404
    .type 'application/json'
    .send
      message: @toString()
      key: @key
      sets: @sets
      stack: @stack.split("\n").slice 1


class NotMapped extends Error
  constructor: (data, name)->
    super "Cannot use '#{log.print data}' to map to '#{name}'"
    @data = data
    @name = name

  send: (res)->
    res.status 500
    .type 'application/json'
    .send
      message: @toString()
      data: @data
      name: @name
      stack: @stack.split("\n").slice 1

module.exports = {NotFound, NotProvided, NotMapped}