stream = require '../../lib/stream'

module.exports = (inputStream, name, options)->
  filters =
    ok: (data) -> data?

    string: (data)->
      if options?.path?
        data = _.get data, options.path
      typeof data == 'string'

  # TODO: make mappers available to: reuse (wahoo!)
  f = filters[name] ? filters.ok

  log.debug 'filter', {name, options}
  inputStream.filter f
