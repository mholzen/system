{fromArgs} = require './query'
searchers = require './searchers'
{isStream, stream} = require './stream'
log = require './log'
resolve = require './resolve'
{isIterable} = require './mappers'

search = (args, options)->
  query = fromArgs args

  results = query.match searchers options

  if not results?
    return null

  stream results
  # TODO: consider a search argument for resolving
  .map (x)-> stream resolve.deep x
  .parallel 10

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

  contentStream = input.observe()
    .filter (x)-> isNew x
    .filter (x)->
      log.debug 'follow testing', {x}
      follow.test x
    .flatMap (x)->
      try
        c = content x
      catch error
        return stream()

      if isStream c
        return c
      if not isIterable c
        c = [c]
      stream c
    # .doto log.debug
    .filter (x)-> x?

  mergePoint.write data
  mergePoint.write contentStream
  mergePoint.end()
  
  # TODO: figure out how to end the content stream when there is no more input
  setTimeout ->
    contentStream.end()
  , 50

  matches


module.exports = search
