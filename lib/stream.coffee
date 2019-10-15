highland = require 'highland'
fs = require 'fs'
log = require '@vonholzen/log'

stream = highland

module.exports = Object.assign stream,
  highland: highland
  stream: stream
