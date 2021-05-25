# TODO: should this be in stream?
{stream, isStream} = require '../../lib/stream'
isIterable = require '../../lib/mappers/isIterable'
parse = require '../../lib/parse'

module.exports = (data)->
  if isStream data
    return data

  if typeof data == 'undefined'
    return stream []

  if isIterable data
    return stream data

  if data?.items?
    return items data.items

  if data instanceof Buffer
    data = data.toString()    # TODO: optimize

  if typeof data == 'string'
    # TODO: use parser
    return stream data.split '\n'

  r = request data
  r = r
  .then (d)->
    if not d?
      log.error 'empty request'
      return []
    parse d
  .catch (e)->
    log.error e
    return []

  throw new Error "cannot get items from #{log.print data}"

module.exports = (data, options)->
  new Date()