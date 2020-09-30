_ = require 'lodash'

omitNames = ['name', 'length']    # names that cannot be assigned to a function

module.exports = (map)->
  # TODO: consider warning or failing if map contains any of omitNames

  create = (name, options)->
    if not (name of map)
      return

    if typeof map[name] == 'function'
      return (data) -> map[name] data, options

    if typeof map[name].create == 'function'
      return map[name].create options

  create.all = map  # make the map accessible

  Object.assign create, _.omit map, omitNames   # make <collection>.<name> accessible