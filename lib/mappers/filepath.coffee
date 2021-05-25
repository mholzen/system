{join} = require 'path'
{NotMapped} = require '../errors'

filepath = (data, options)->
  # log.debug 'filepath.entry', {data, options}
  if typeof data == 'string'
    return data

  if typeof data?.path == 'string'
    return data?.path

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return join directory, data.name

  throw new NotMapped data, 'filepath'

module.exports = filepath
