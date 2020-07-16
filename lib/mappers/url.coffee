module.exports = (data)->

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
