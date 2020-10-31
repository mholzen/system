log = require '../log'
path = require 'path'

types =
  'css': 'text/css'
  'jpg': 'image/jpeg'
  'jpeg': 'image/jpeg'
  'gif': 'image/gif'
  'html': 'text/html'
  'txt': 'text/plain'
  'md': 'text/plain'
  'png': 'image/png'
  'csv': 'text/csv'
  'json': 'application/json'

name = (data)->
  data?.filename ? data?.name

type = (data, context)->
  if types[data]?
    return types[data]

  if typeof data == 'object'
    if name(data)?
      extension = path.extname name data
      if extension?
        extension = extension.slice(1)

      if extension of types
        log.debug 'returning', {type: types[extension]}
        return types[extension]

type.types = types

module.exports = type