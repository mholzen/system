{join} = require 'path'
{NotMapped} = require '../errors'

base = (data)->
  data?.base ? data?.req?.dirname

filepath = (data, options)->
  # log {data, p:data?.path, options}
  if data?.path?
    data = data.path

  if data instanceof Array
    data = join data...

  if not data?
    b = base options
    if b?
      return b

  if typeof data == 'string'
    if not data.startsWith '/'
      b = base options
      if b?
        data = join b, data
    return data

  if typeof data?.name == 'string'
    directory = data?.directory ? '.'
    return join directory, data.name

  throw new NotMapped data, 'filepath'

module.exports = filepath
