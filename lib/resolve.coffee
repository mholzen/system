{isStream} = require './stream'
isPromise = require 'is-promise'
{traverse} = require '../lib/traverse'
log = require './log'
_ = require 'lodash'

resolve = (data)->
  if not data?
    return null
  if isPromise data
    return data.then (d)-> resolve d
  if isStream data
    return data.fork().collect().toPromise Promise
  if typeof data == 'object'
    return Promise.all Object.keys(data).map (key)->
      if isPromise data[key]
        return data[key].then (value)->data[key] = value
    .then ->
      data
  new Promise (resolve)-> resolve data

resolve.deep = (data)->
  nodes = Array.from traverse data, path: true
  log.debug 'resolve.deep', {nodes}
  promises = nodes.map (match)->
    resolve match.value
    .then (value)->
      _.set data, match.path, value
    .catch (error)->    # TODO: make this behaviour depend on options
      _.set data, match.path, error

  Promise.all promises
  .then ->
    data


module.exports = resolve