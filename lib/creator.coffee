_ = require 'lodash'
log = require './log'
{Arguments} = require './mappers/args'

omitNames = ['name', 'length']    # names that cannot be assigned to a function

# TODO: rename FunctionFactory or FunctionCreator

# TODO: move to global
class NotFound extends Error
  constructor: (message, set)->
    super message
    @set = set
  toString: ->
    @message + " in #{@set}"

module.exports = (map)->
  # Returns factory function given a map of [name, factoryFunction] which passes arguments from the factory to the individual factory function
  # only works if factoryFunction takes one argument
  # which means it won't work for reducer functions

  # TODO: refactor to a mapper
  find = (data)->
    if typeof data == 'undefined'
      throw new NotFound "cannot find without name", Object.keys map

    if Array.isArray data
      m = map
      for segment in data
        if not (segment of m)
          throw new NotFound "cannot find '#{segment}'", Object.keys map
        m = m[segment]
      return m

    if typeof data == 'string'
      if not (data of map)
        throw new NotFound "cannot find '#{data}'", Object.keys map

      return map[data]

    throw new NotFound "cannot find given '#{data}'", Object.keys map

  # TODO: consider warning or failing if map contains any of omitNames
  create = (name, args...)->
    # log.debug 'creator', {name, args}
    # if typeof name == 'undefined'
    #   throw new NotFound "cannot find without name", Object.keys map

    # if typeof name == 'object'
    #   # if typeof name[0] == 'undefined'
    #   #   throw new Error "cannot find without a name"
    #   throw new Error "cannot find given a '#{name.constructor.name}'"

    # if not (name of map)
    #   return

    # same pattern as inodePath, in other words: return an object that represents the path and the remainder

    f = find name
    # if typeof map[name] == 'function'
    if typeof f == 'function'
      return (data, a...) ->
        if a.length > 0
          throw new Error 'unary function called with more arguments'
        # TODO: consider wrapping the error hanlding in another function
        try
          # TOFIX: this doesn't work when map[name] is a reducer function
          # console.log 'calling factory function', {name, v: args[0]}
          f data, args...
        catch e
          if options?.errors?.ignore
            log.error 'in creator', e
            return e
          else
            throw e

    if typeof f?.create == 'function'
      return f.create args...

    throw new Error "name '#{name}' identifies a map, not a function"

  create.all = map  # make the map accessible

  create.signature = Arguments.Signature.from Object.keys map

  Object.assign create, _.omit map, omitNames   # make <collection>.<name> accessible
