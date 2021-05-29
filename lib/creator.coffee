_ = require 'lodash'
log = require './log'
{Arguments} = require './mappers/args'

omitNames = ['name', 'length']    # names that cannot be assigned to a function

# TODO: rename FunctionFactory or FunctionCreator

{NotFound, NotProvided} = require './errors'

module.exports = (map)->
  # Returns factory function given a map of [name, factoryFunction] which passes arguments from the factory to the individual factory function
  # only works if factoryFunction takes one argument
  # which means it won't work for reducer functions

  # TODO: refactor to a mapper
  find = (data)->
    if typeof data == 'undefined'
      throw new NotProvided 'data'

    if Array.isArray data
      m = map
      for segment in data
        if not (segment of m)
          throw new NotFound segment, map
        m = m[segment]
      return m

    if typeof data == 'string'
      if not (data of map)
        throw new NotFound data, map

      return map[data]

    throw new NotFound data, map

  # TODO: consider warning or failing if map contains any of omitNames
  create = (name, args...)->
    # log.debug 'creator', {name, args}

    # same pattern as inodePath, in other words: return an object that represents the path and the remainder

    f = find name
    # if typeof map[name] == 'function'
    if typeof f == 'function'

      # TODO: should pass index and array into options
      return (data, a...) ->
        if a.length > 0
          throw new Error "unary function called with more than 1 argument '#{log.print a}'"
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
