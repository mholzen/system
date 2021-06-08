class NotProvided extends Error
  # TODO: could list available options
  constructor: (name)->
    super "'#{name}' is required but undefined"
    @name = name

class NotFound extends Error
  constructor: (key, sets...)->
  # TODO: nice to have: names for sets
    if typeof key == 'undefined'
      super "NotFound: cannot find without a key"
    else
      super "NotFound: cannot find '#{key}'"
    @key = key
    @sets = sets.map (set)->
      if not set?
        return set
      if not (set instanceof Array)
        set = Object.keys set
      set.sort()
    # TODO: warn if @sets is empty

  toString: ->
    @message + " in sets #{log.print @sets}"

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
    super "NotMapped: cannot use '#{log.print data}' to map to '#{name}'"
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