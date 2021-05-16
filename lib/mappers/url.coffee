# TODO: this probably should come from the context
urlNames =
  thumbnails: '/files/test/artifacts/thumbnails.css'

url = (data, options)->
  if options?.req?
    return 'should use base'

  if data?.name?
    if data.name of urlNames
      return urlNames[data.name]

  if typeof data == 'string'
    if data.match /https*:\/\/[^/]+/
      return data
    if data.match /\w+\.\w+/
      return "http://#{data}/"

  if data?.url?
    return data.url

  if data?.path?
    return 'file://' + data.path

  throw new Error "cannot get url from #{data}"

module.exports = url