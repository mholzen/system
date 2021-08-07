log = require './log'

keys = (sets)->
  sets.map (set)->
    if not set?
      return set
    if not (set instanceof Array)
      set = Object.keys set
    set.sort()

class NotProvided extends Error
  constructor: (name, sets...)->
    super "'#{name}' is required but was not provided"
    @name = name
    @sets = keys sets

  toString: ->
    @message + ". Available choices are: #{log.print @sets}"

  send: (res)->
    res.status 404
    .type 'application/json'
    .send
      message: @toString()
      name: @name
      sets: @sets
      stack: @stack.split("\n").slice 1

class NotFound extends Error
  constructor: (key, sets...)->
  # TODO: nice to have: names for sets
    if typeof key == 'undefined'
      super "NotFound: cannot find without a key"
    else
      super "NotFound: cannot find '#{key}'"
    @key = key
    @sets = keys sets
    # TODO: should fail/warn if @sets is empty to:discover

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
      data: log.print @data
      name: @name
      stack: @stack.split("\n").slice 1

module.exports = {NotFound, NotProvided, NotMapped}