{NotMapped} = require '../../lib/errors'
mappers = require '../../lib/mappers'

module.exports = (inputStream, name, options)->
  f = mappers name
  if not f?   # TODO: encapsulate into mappers.get to:reuse
    throw new NotMapped name, mappers

  notF = (f)->
    ->
      not f arguments...

  inputStream.filter notF f
