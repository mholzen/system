{isStream} = require './stream'
isPromise = require 'is-promise'
{create} = require './iterators/traverse'
log = require './log'
_ = require 'lodash'

traverse = create()

resolve = (data)->
  # log 'resolve.entry', {data}
  if not data?
    return null

  if isPromise data
    # log 'resolve promise'
    return data.then (d)->
      # log 'resolve promise resolved'
      resolve d

  if isStream data
    return data.fork().collect().toPromise(Promise).then (d)->resolve d

  if typeof data == 'object'
    # log 'resolve object', {data}
    return Promise.all Object.keys(data).map (key)->
      if isPromise data[key]
        # log 'adding promise resolver', {key}
        return data[key].then (value)->
          # log "promise resolver called #{value}"
          data[key] = value
    .then ->
      # log "final object promise resolver called #{log.print data}"
      data

  # log 'resolve returning promise'
  new Promise (resolve)-> resolve data

resolve.deep = (data)->
  nodes = Array.from traverse data    # TODO: traverse looking for Promise specifically
  log 'resolve.deep', {nodes}
  promises = nodes.map (match)->
    resolve match.value     # traverse is deep, so this resolve can be shallow
    .then (value)->
      log 'resolve setting value', {path: match.path, value}
      if match.path.length == 0
        log "assiging", {data, value}
        Object.assign data, value
      else
        _.set data, match.path, value
    .catch (error)->    # TODO: make this behaviour depend on options
      # log 'resolve setting error', {error}
      _.set data, match.path, error

  Promise.all promises
  .then ->
    console.log 'all resolved'
    data


module.exports = resolve