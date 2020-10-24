log = require '../log'
path = require 'path'

types =
  'css': 'text/css'
  'jpg': 'image/jpeg'
  'html': 'text/html'
  'txt': 'text/plain'
  'png': 'image/png'
  'csv': 'text/csv'
  'json': 'application/json'

type = (data, context)->
  if types[data]?
    return types[data]

  if typeof data == 'object'
    if data.filename?
      extension = path.extname data.filename
      if extension?
        extension = extension.slice(1)

      if extension of types
        log.debug 'returning', {type: types[extension]}
        return types[extension]

type.types = types

module.exports = type