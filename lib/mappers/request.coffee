requestPromise = require 'request-promise'    # TODO: replace with node-fetch so:modern
inodes = require '../inodes'
url = require './url'
filepath = require './filepath'
{isStream} = require '../stream'

request = (data)->

  # if data instanceof Promise
  #   # WARN: this `await` makes `request` return a promise.
  #   # this promise resumes here?
  #   return request await data

  if isStream data
    return data.each (i)-> request i

  # try

  log 'request', {url: url data}
  return requestPromise
    uri: url data
    simple: false # reject only if the request failed without a response
    resolveWithFullResponse: true

  # catch e
  #   try
  #     return inodes filepath data
  #   catch
  #     throw new Error "cannot make a filepath from 1'#{log.print data}'"
  # throw new Error "cannot make a request from 2'#{log.print data}'"
  # inodes filepath data

request.request = request

module.exports = request
