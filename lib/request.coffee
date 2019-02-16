requestPromise = require 'request-promise'
log = require '@vonholzen/log'
url = require './map/url'

isURL = (data)->
  if typeof data == 'object'
    data = url data
  if typeof data == 'string'
    return /https?:\/\//.test data

isFilename = (data)->

isReference = (data)->


request = (resource)->
  if not resource.url?
    resource =
      url: url resource

  if not resource.method
      method: 'GET'

  await requestPromise
    uri: resource.url
    simple: false # reject only if the request failed without a response
    resolveWithFullResponse: true

module.exports = request
