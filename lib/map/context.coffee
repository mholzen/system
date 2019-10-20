log = require '../log'

module.exports = (data, options)->
  # TODO: could accept named contexts, such as "url", "person", etc...
  # will need to look at options.root to determine true context

  if typeof data != 'object'
    return data

  if data?.path instanceof Array
    return data.path.slice 0,-2

  throw new Error "no path in '#{typeof data}'"
