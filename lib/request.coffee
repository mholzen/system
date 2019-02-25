requestPromise = require 'request-promise'
inodes = require './inodes'
url = require './map/url'
filepath = require './map/filepath'

log = require '@vonholzen/log'

request = (data)->
  u = url data

  try
    return requestPromise
      uri: url data
      simple: false # reject only if the request failed without a response
      resolveWithFullResponse: true

  catch e
    console.log e
    try
      return inodes filepath data
    catch
      throw new Error "cannot make a request from #{data}"
  throw new Error "cannot make a request from #{log.toPrettyString data}"

module.exports = request
