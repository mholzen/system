{NotMapped} = require '../../lib/errors'
stream = require '../../lib/stream'
mappers = require '../../lib/mappers'
getFunction = require '../../lib/mappers/function'

create = (name, options)->
  # f = mappers name
  f = getFunction name, options
  stream.filter f

module.exports = (inputStream, name, options)->
  f = getFunction name, options
  # log.debug 'filter', {name, options}
  inputStream.filter f

module.exports.create = create
