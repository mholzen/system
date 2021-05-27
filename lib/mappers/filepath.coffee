{join} = require 'path'
{NotMapped} = require '../errors'

filepath = (data, options)->
  # log.debug 'filepath.entry', {data, p:data?.path, options}
  if data?.path?
    data = data.path

  if data instanceof Array
    data = join data...
    # log.debug 'filepath.data was array', {data}

  if typeof data == 'string'
    if options?.req?.dirname?
      if not data.startsWith '/'
        data = join options.req.dirname, data
    return data

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return join directory, data.name

  throw new NotMapped data, 'filepath'

module.exports = filepath
