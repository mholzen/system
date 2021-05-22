{NotProvided} = require '../errors'
{items} = require './items'
isIterable = require '../mappers/isIterable'

create = (options)->
  query = options?.query ? options
  if not query
    throw new NotProvided 'options.query or query'

  return (data)->
    if not isIterable data
      try
        data = items data
      catch e
        log.error 'query', {e}
        return

    query.search data

module.exports = {create}