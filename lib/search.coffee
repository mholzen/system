{fromArgs} = require './query'
searchers = require './searchers'
{stream, isStream} = require './stream'
{Match} = require './match'
isPromise = require 'is-promise'
log = require './log'
resolve = require '../lib/resolve'

isMatch = (x)->
  (x?.path instanceof Array) and ('value' of x)

flatten = (match)->
  if isPromise match
    return stream match

  if isStream match.value
    return match.value.map (match)->match.prepend match.path

  if isPromise match.value
    return stream match.value.then (item)->
      if item instanceof Match
        return item.prepend match.path
      return new Match item, match.path

  stream [ new Match match.value, match.path ]

flatten2 = (x)->
  if x instanceof Array
    return x.map flatten
  if not isMatch x
    return x
  # x isMatch
  if x.value instanceof Array
    return x.value.map (m)->
      if not isMatch m
        return m
      # here to flatten deep
      (new Match m.value, m.path).prepend x.path

  if not isMatch x.value
    return x
  # x.value isMatch
  m = new Match x.value.value, x.value.path
  return m.prepend x.path


search = (args)->
  query = fromArgs args

  results = query.match searchers()
  log.debug 'search', {results}

  if not results?
    return null

  stream results
  .doto (x)->log.debug {x}
  # TODO: consider a search argument for resolving
  .map (x)-> stream resolve.deep x
  .parallel 10

  # .flatMap flatten
  # .flatMap (x)->
  #   x = flatten2 x
  #   if not (x instanceof Array)
  #     x = [ x ]
  #   stream x

module.exports = search
