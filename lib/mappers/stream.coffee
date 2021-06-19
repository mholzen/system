stream = require '../stream'
parse = require './parse'
fs = require 'fs'

module.exports = (data, options)->
  if data instanceof fs.ReadStream
    return stream data
    .through parse

  return stream parse data

Object.assign module.exports, {isStream: stream.isStream}