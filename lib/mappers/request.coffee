requestPromise = require 'request-promise'
inodes = require '../inodes'
url = require './url'
filepath = require './filepath'
{isStream} = require '../stream'

log = require '@vonholzen/log'

request = (data)->

  if data instanceof Promise
    return request await data

  if isStream data
    return data.each (i)-> request i

  try
    log 'request', {data}
    return requestPromise
      uri: url data
      simple: false # reject only if the request failed without a response
      resolveWithFullResponse: true

  catch e
    try
      return inodes filepath data
    catch
      throw new Error "cannot make a filepath from #{log.toPrettyString data}"
  throw new Error "cannot make a request from #{log.toPrettyString data}"

request.request = request

module.exports = request
