_ = require 'lodash'
log = require './log'

omitNames = ['name', 'length']    # names that cannot be assigned to a function

# TODO: rename FunctionFactory or FunctionCreator

module.exports = (map)->
  # TODO: consider warning or failing if map contains any of omitNames

  create = (name, args...)->
    if not (name of map)
      return

    if typeof map[name] == 'function'
      return (data) ->
        # TODO: consider wrapping the error hanlding in another function
        try
          map[name] data, args...
        catch e
          if not options?.errors?.throw
            log.error e
            return e
          else
            throw e

    if typeof map[name].create == 'function'
      return map[name].create args...

  create.all = map  # make the map accessible

  Object.assign create, _.omit map, omitNames   # make <collection>.<name> accessible