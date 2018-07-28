requestPromise = require 'request-promise'
log = require '@vonholzen/log'
url = require './url'

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
