# TODO: this probably should come from the context

{NotMapped} = require '../errors'

urlNames =
  thumbnails: '/files/cwd/test/artifacts/thumbnails.css'

url = (data, options)->
  if options?.req?
    throw new Error 'should use base'

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