stream = require 'highland'
log = require '@vonholzen/log'
{createQuery} = require './lib/query'

searchers = [
  require './lib/file'
  # require './lib/application'
  # require './lib/json'
  require './lib/bookmarks'
  require './lib/urlQueries'
  # require './lib/url'
  # require './lib/sql'
  # require './lib/sparql'
]

searcher =
  createQuery: createQuery

  find: (query)->
    if typeof query == 'function'
      searchers.find query

  head: (query)-> query?.type == 'searcher'

  search: (query, options)->
    log 'searcher.search', query
    query = createQuery query, options

    if query.type? and query.type
      searchers = searchers.filter (s)->s.types?.includes query.type
      log 'searchers', {type: query.type}, {s: searchers.map (s)->s.types}

    if not options?.recurse
      # log 'not recursing'
      return stream(searchers)

    results = stream(searchers).map (searcher)->
      out = stream()
      searcher.search query, out
      out
    .merge()

    if options?.limit?
      log 'limit', options.limit
      results = results.take(parseInt options.limit)

    if options?.duration?
      setTimeout ->
        results.end()
      , options.duration

    return results

# the root searcher
searchers.push searcher
searchers.search = searcher

module.exports = searcher
