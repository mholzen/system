highland = require 'highland'
fs = require 'fs'
log = require '@vonholzen/log'

stream = (data)->
  log 'stream', {data}
  if typeof data == 'string'
    data = if data.startsWith('http://') or data.startsWith('https://')
      url: data
    else
      path: data

  if data?.path?
    readStream = fs.createReadStream(data.path)
    data = readStream

  highland(data)

stream.strings = (data)->
  stream(data).split().filter (line) -> line.length > 0

stream.highland = highland
stream.nil = highland.nil
stream.isStream = highland.isStream
stream.stream = stream

module.exports = stream
