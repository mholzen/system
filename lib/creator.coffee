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

module.exports = (map)->
  # Returns factory function given a map of [name, factoryFunction] which passes arguments from the factory to the individual factory function
  # only works if factoryFunction takes one argument
  # which means it won't work for reducer functions

  # TODO: consider warning or failing if map contains any of omitNames
  create = (name, args...)->
    # log.debug 'creator', {name, args}
    if typeof name == 'undefined'
      throw new NotFound "cannot find without name", Object.keys map

    if typeof name == 'object'
      if typeof name[0] == 'undefined'
        throw new Error "cannot find without a name"

      throw new Error "cannot find based on an object '#{name.constructor.name}'"

    if not (name of map)
      return

    if typeof map[name] == 'function'
      return (data, a...) ->
        if a.length > 0
          throw new Error 'unary function called with more arguments'
        # TODO: consider wrapping the error hanlding in another function
        try
          # TOFIX: this doesn't work when map[name] is a reducer function
          # console.log 'calling factory function', {name, v: args[0]}
          map[name] data, args...
        catch e
          if options?.errors?.ignore
            log.error 'in creator', e
            return e
          else
            throw e

    if typeof map[name].create == 'function'
      return map[name].create args...

  create.all = map  # make the map accessible

  create.signature = Arguments.Signature.from Object.keys map

  Object.assign create, _.omit map, omitNames   # make <collection>.<name> accessible
