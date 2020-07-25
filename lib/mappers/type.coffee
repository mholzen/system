log = require '../log'
path = require 'path'

types =
  'css': 'text/css'
  'jpg': 'image/jpeg'
  'html': 'text/html'
  'text': 'text/plain'
  'png': 'image/png'
  'csv': 'text/csv'

type = (data, context)->
  if types[data]?
    return types[data]

  if typeof data == 'object'
    if data.filename?
      extension = path.extname data.filename
      if extension of types
        return types[extension]

type.types = types

module.exports = type