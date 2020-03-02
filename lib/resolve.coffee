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
    log.debug 'resolving', {match}
    resolve match.value
    # if isStream match.value
    #   match.value = match.value.fork().collect().toPromise Promise

    # if not isPromise match.value
    #   return match.value
    
    # match.value
    .then (value)->
      _.set data, match.path, value

    # resolve node
  Promise.all promises
  .then ->
    data


module.exports = resolve