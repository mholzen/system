makeCreator = (map)->
  (name, options)->
    if not (name of map)
      return

    if typeof map[name] == 'function'
      return (data) -> map[name] data, options

    if typeof map[name].create == 'function'
      return map[name].create options

module.exports = {makeCreator}