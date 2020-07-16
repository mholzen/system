{query, fromArgs} = require './query'
searchers = require './searchers'
{isStream, stream} = require './stream'
log = require './log'
resolve = require './resolve'
{isIterable, args, content} = require './mappers'
isPromise = require 'is-promise'

resolver = (s)->
  s
  .map (x)-> stream resolve.deep x
  .parallel 10
  .filter (x) -> x?.value? and (not x?.value?.length? or x?.value?.length > 0)

search = (args, options)->
  query = fromArgs args
  results = query.match searchers options
  if not results?
    return null

  stream results
  # TODO: consider a search argument for resolving
  .through resolver

search.search2 = (data, options)->
  a = args data

  follow = query a?.follow
  delete a.follow

  searcherOptions = a?.searchers
  delete a.searchers
  s = searchers searcherOptions
  log.debug {s}

  q = query a

  options ?= {}
  options.content = content

  results = search.searchIn q, follow, stream([s]), options
  results.through resolver

search.searchIn = (match, follow, data, options)->
  content = options?.content

  mergePoint = stream()

  input = mergePoint
  .merge()
  .map (x) -> stream resolve x
  .parallel 10

  matches = input
    .filter (x)->
      log.debug 'data testing', {x}
      match.test x

  isNew = (x)->true
  
  contentCount = 0
  inc = ->
    contentCount++
    log.debug 'contentCount', {contentCount}
  dec = ->
    contentCount--
    log.debug 'contentCount', {contentCount}
  close = (s)->
    if contentCount <= 0
      log.debug 'closing content'
      s.end()   # Doc recommends never calling on stream that were created without a source

  contentStream = input.observe()
    .doto inc
    .flatFilter (x)->
      test = follow.test(x)
      if isStream test
        return test.observe().done ->
          if not x
            dec()
        
      if not isPromise test
        test = new Promise (resolve)->resolve test
      
      test = test.then (x)->
        log.debug 'follow testing', {follow, x}
        if not x
          dec()
        x
      
      stream test
    # .filter (x)->
    #   test = isNew(x) and follow.test(x)
    #   if not test
    #     dec()

    #   log.debug 'follow testing', {test, follow, x}
    #   test
    .map (x)->
      try
        c = content x
        log.debug 'content', {c}
      catch error
        console.log error.toString()
        return stream()

      if isStream c
        return c
      if not isIterable c
        c = [c]
      stream c
    .map (x)->
      x.observe().done ->
        dec()
        close contentStream
      x
    .flatMap (x)->x
    .filter (x)->
      log.debug 'filter', {x}
      x?  # is this needed because x can contain a promise?
  
  mergePoint.write data
  mergePoint.write contentStream
  mergePoint.end()
  
  # TODO: figure out how to end the content stream when there is no more input
  setTimeout ->
    contentStream.end()
  , 200

  matches


module.exports = search
