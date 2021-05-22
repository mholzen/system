{NotMapped} = require '../errors'

filepath = (data, options)->
  if typeof data == 'string'
    return data

  if typeof data?.path == 'string'
    return data?.path

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return path.join directory, data.name

  throw new NotMapped data, 'filepath'

module.exports = filepath
