_ = require 'lodash'

omitNames = ['name', 'length']    # names that cannot be assigned to a function

makeCreator = (map)->
  create = (name, options)->
    if not (name of map)
      return

    if typeof map[name] == 'function'
      return (data) -> map[name] data, options

    if typeof map[name].create == 'function'
      return map[name].create options

  create.all = map  # make the map accessible
  Object.assign create, _.omit map, omitNames

module.exports = {makeCreator}