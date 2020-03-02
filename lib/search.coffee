{fromArgs} = require './query'
searchers = require './searchers'
{stream} = require './stream'
log = require './log'
resolve = require './resolve'

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

module.exports = search
