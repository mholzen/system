{isStream} = require './stream'
isPromise = require 'is-promise'
{create} = require './traverse'
log = require './log'
_ = require 'lodash'

traverse = create()

resolve = (data)->
  # log.debug 'resolve.entry', {data}
  if not data?
    return null

  if isPromise data
    # log.debug 'resolve promise'
    return data.then (d)->
      # log.debug 'resolve promise resolved'
      resolve d

  if isStream data
    return data.fork().collect().toPromise Promise

  if typeof data == 'object'
    log.debug 'resolve object'
    return Promise.all Object.keys(data).map (key)->
      if isPromise data[key]
        return data[key].then (value)->data[key] = value
    .then ->
      data

  # log.debug 'resolve returning promise'
  new Promise (resolve)-> resolve data

resolve.deep = (data)->
  nodes = Array.from traverse data
  # log.debug 'resolve.deep', {nodes}
  promises = nodes.map (match)->
    resolve match.value
    .then (value)->
      # log.debug 'resolve setting value', {value}
      _.set data, match.path, value
    .catch (error)->    # TODO: make this behaviour depend on options
      # log.debug 'resolve setting error', {error}
      _.set data, match.path, error

  Promise.all promises
  .then ->
    # log.debug 'all resolved'
    data


module.exports = resolve