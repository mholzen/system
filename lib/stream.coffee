highland = require 'highland'
fs = require 'fs'
log = require '@vonholzen/log'

stream = highland

stream.strings = (data)->
  stream(data).split().filter (line) -> line.length > 0

module.exports = Object.assign stream,
  highland: highland
  nil: highland.nil
  isStream: highland.isStream
  stream: stream
