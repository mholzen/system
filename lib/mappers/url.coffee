# TODO: this probably should come from the context
{NotMapped} = require '../errors'

urlNames =
  thumbnails: '/files/test/artifacts/thumbnails.css'

url = (data, options)->
  if options?.req?
    options.res.type 'text/plain'
    log.debug 'url', {segments: options.req.params.segments}
    return '/' + options.req.params.segments.slice(0,-1).join '/'

  if data?.name?
    if data.name of urlNames
      return urlNames[data.name]

  if typeof data == 'string'
    if data.match /^https*:\/\/[^/]+/
      return data
    if data.match /^\w+\.\w+/
      return "https://#{data}"

  if data?.url?
    return data.url

  if data?.path?
    return 'file://' + data.path

  throw new NotMapped data

module.exports = url