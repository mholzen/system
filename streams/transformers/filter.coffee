{NotMapped} = require '../../lib/errors'
stream = require '../../lib/stream'
mappers = require '../../lib/mappers'

create = (name, options)->
  f = mappers name
  stream.filter f

module.exports = (inputStream, name, options)->
  filters =
    ok: (data) -> data?

    string: (data)->
      if options?.path?
        data = _.get data, options.path
      typeof data == 'string'

  # TODO: make mappers available to: reuse (wahoo!)
  # f = filters[name] ? filters.ok

  f = mappers name
  if not f?   # TODO: encapsulate into mappers.get to:reuse
    throw new NotMapped name, mappers

  # log.debug 'filter', {name, options}
  inputStream.filter f

module.exports.create = create

