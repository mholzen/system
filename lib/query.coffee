_ = require 'lodash'
log = require '@vonholzen/log'
{stream, isStream} = require './stream'
content = require './mappers/content'
{parseValue} = require './parse'
isIterable = require './mappers/isIterable'
{startsWith, intersect, Match, Matches} = require './match'
{Results} = require './results'
isPromise = require 'is-promise'

isLiteral = (x)->
  ['number', 'boolean', 'symbol'].includes typeof x

class Query
  setQuery: (query) ->
    @query = query ? null
    @path = true
    @streams = new Set()
    switch
      when query instanceof Query
        _.assign(this, query)
      when typeof query == 'undefined'
        @_match = (data)-> data
      when typeof query == 'boolean'
        @_match = @booleanMatch
      when typeof query == 'number'
        @_match = @numberMatch
      when typeof query == 'string'
        @_match = @stringMatch
      when typeof query == 'function'
        @_match = query
      when query instanceof RegExp
        @_match = @regexpMatch
      when query instanceof Array
        @query = query.map (x)->new Query x
        @_match = @arrayMatch
      when typeof query == 'object'
        @_match = @objectMatch
      else
        throw new Error "unknown query type #{typeof query}"

  constructor: (query, options)->
    # log.debug 'query.constructor', {query, options}

    @options = options ? {}

    @options.recurse ?= false
    @options.partialMatches ?= false

    if options?.limit?
      @options.limit = parseInt options.limit

    @setQuery query

  recurse: ->
    if typeof @options.recurse == 'boolean'
      return @options.recurse
    if typeof @options.recurse == 'number'
      return @options.recurse > 0

  booleanMatch: (data)->
    if typeof data == 'boolean'
      if data == @query
        return data
      return null
    else
      (typeof data != 'undefined') == @query

  _objectMatchMap: (data)->
    f = (matches, entry) =>

      [key, value] = entry

      # match key?
      keyQuery = @query[key] ? @query
      if query(keyQuery).test key
        matches.push new Match [key, value]

      # match value?
      if not (results = @match value, results:true)
        return matches
      results.prepend key
      return matches.concat results.toArray()

    Array.from(data).reduce f, []

  _objectMatch: (data)->
    matches = []
    for key, value of data

      keyQuery = @query[key] ? @query
      if query(keyQuery).test key
        matches.push new Match {[key]: value}

      if (m = @match value, results:true)
        m.prepend [key]
        matches = matches.concat m.toArray()

    if _.isEmpty matches
      return null

    return matches

  numberMatch: (data)->
    if typeof data == 'string'
      data = _.toNumber data

    if data instanceof Array
      return data.filter (d)=> @match d

    if typeof data == 'object'
      return @_objectMatch data

    if typeof data == 'number'
      return if @query == data
        [data]
      else
        null

    throw new Error "number query against '#{typeof data}' data"

  stringMatch: (data)->
    if ['number', 'boolean', 'symbol'].includes typeof data
      if data.toString() == @query
        return [data]
      else
        return null

    if typeof data == 'string'
      if @query.startsWith '-'
        return not data?.includes @query.slice(1)
      if data == @query
        return [data]
      return null

    if typeof data == 'function' or typeof data == 'undefined'
      return null

    if typeof data == 'object'
      return @_objectMatch data

    throw new Error "string query against '#{typeof data}' data"

  regexpMatch: (data)->
    if ['number', 'boolean', 'symbol'].includes typeof data
      if @query.exec data.toString()
        return [data]
      else
        return null

    if typeof data == 'function' or typeof data == 'undefined'
      return null

    if typeof data == 'string'
      r = @query.exec data
      if r == null
        return null
      return [new Match r[0], [r.index]]

    if typeof data == 'object'
      return @_objectMatch data

    throw new Error "regexp query against '#{typeof data}' data"

  objectMatch: (data)->
    if ['string', 'number', 'boolean', 'symbol'].includes typeof data
      return null

    if typeof data == 'object'
      matches = []
      match = new Match {}
      path = {}
      for key, value of data

        if @query[key]?
          if (m = query(@query[key]).match value)
            if m.length > 1
              throw new Error "ignoring results #{m}"
            m = m[0]
            match.value[key] = m.value ? m
            if m.path?.length > 0
              path[key] = m.path

        else
          if ((typeof value == 'object') and (m = @match value))
            if not (m instanceof Array)
              m = [m]

            for m1 in m
              m1 = new Match m1?.value ? m1, m1?.path
              m1.path.unshift key
              matches.push m1

      if not _.isEmpty match.value
        if not _.isEmpty path
          match.path.push path
        matches.push match

      if _.isEmpty matches
        return null

      if matches.length == 0
        return null

      return matches

    throw new Error "cannot query object against '#{typeof data}' data #{data}"

  _joinMatches: (matches)->
    isRegeExpAnswer = (a)->
      typeof a?[0] == 'string' and
      typeof a?.index == 'number' and
      typeof a?.input == 'string'

    add = (a,b)->
      if typeof a == 'string'
        if a != b
          throw new Error "joining different strings matches (#{a},#{b})"
        return a

      if typeof a == 'object'
        if isRegeExpAnswer(a) and isRegeExpAnswer(b)
          start = Math.max(a.index, b.index)
          end = Math.min(a.index+a[0].length, b.index+b[0].length)
          if start >= end
            return null

          result = [a.input[start..end]]
          result.index = start
          result.input = a.input
          return result

        if a.path? and b.path?
          if a.path.length > b.path.length
            if startsWith a.path, b.path
              return a
          else
            if startsWith b.path, a.path
              return b
          return null

      throw new Error "adding '#{typeof a}' value neither object or string"

    matches.reduce (result, match)->
      add result, match

  arrayMatch: (data)->
    if @query.length == 0
      return [new Match data]

    f = (matches, query, i) ->
      query.match matches, results:true

    s = @query.reduce f, data
    if s == null 
      return null

    s = s.toArray()

    if s?.length == 0
      return null
    return s

  test: (data)->
    return true if @query == null
    match = @match data
    # log.debug 'query', {match}
    if isPromise match
      return match.then (x) -> not (x == null or x[0] == null)
    if isStream match
      return match.filter (x)-> not (x == null or x[0] == null)
    if match == null or match[0] == null
      return false
    true

  match: (data, options)->
    # log.debug 'query.match', {query: @query, data}
    r = @matchReturnsArray data, options
    # log.debug 'query.match returns', {r}

    if not r?
      return null

    if r?.length == 0
      return null

    if isLiteral r
      return r

    if options?.results
      if isPromise r
        return new Results r

      if r instanceof Results
        return r

      if r instanceof Array
        r = r.map (x) -> Match.toMatch x
      return new Results r.map (x)->[x.path, x.value]
    else
      return r

  matchReturnsArray: (data, options)->
    if typeof data == 'undefined'
      return null

    if data == null
      if @query == null
        return [new Match data]
      else
        return null

    if @query == null
      return [new Match data]

    if data instanceof Results
      return @match data.values

    if data instanceof Match
      matches = @match data.value
      if matches == null
        return null
      if isPromise matches
        return matches.then (x)->
          x.map (m)->m.prepend data.path

      return matches.map (m)->
        m.prepend data.path

    if stream.isStream data
      return data.fork().filter (item) => @match item

    if isPromise data
      return data.then (d) => @match d, options

    if data instanceof Array
      return data.map (item, i) =>
        m = @match(item, results:true)
        m?.prepend [i]
      .filter (matches) -> matches?
      .map (r) -> r.toArray()
      .flat()

      if results.length == 0
        return null
      return results

    if (typeof data[Symbol.iterator] == 'function') and (typeof data != 'string')
      return @_objectMatchMap data

    match = @_match data
    if match == null
      return null

    if not ([@stringMatch, @arrayMatch, @numberMatch, @regexpMatch, @objectMatch].includes @_match)
      match = [ match ]

    return match

  partialMatch: (data)->
    pre = @options.partialMatch
    result = @match data
    @options.partialMatch = pre
    return result

  isEmpty: ->
    @query.length == 0

  nonMatches: (value)->
    if not (@query instanceof Array)
      throw new Error "nonMatches on #{typeof @_match} query"

    new Query @query.filter (subquery)->
      not query(subquery).test value

  and: (query)->
    new Query (value)=>
      if @test(value) and query.test(value)
        return @_match value
      else
        null

  toJSON: -> {matches: @matches, options: @options}

  toString: ->
    return if @model?
      JSON.stringify @model
    else
      @matches?.join ' '

  search: (data, options)->
    log 'search', {data}
    if not isIterable data
      data = [ data ]

    if not isStream data
      data = stream data

    options = options ? {}
    output = options.output ? stream()
    resultStreams = stream()
    mergedResults = resultStreams.merge()   # TODO: consider moving to end of function
    resultStreams.write output

    data.each (item)=>

      if not @recurse()
        if @test item
          output.write @match(item)[0]
        return

      unmetMatches = @nonMatches item

      if typeof @options.recurse == 'number'
        unmetMatches.options.recurse = @options.recurse - 1

      try
        subResults = stream()
        resultStreams.write subResults

        unmetMatches.searchIn item, {output: subResults}
      catch error
        # log.debug 'query.search error', {error, e: error instanceof Error }
        throw error

    .done ->
      # log.debug 'query.search done'
      output.end()
      resultStreams.end()

    return mergedResults

query = (terms, options)->
  new Query terms, options

query.query = query
query.Query = Query
query.createQuery = query

optionNames = [ 'duration', 'depth', 'limit', 'recurse' ]
query.optionNames = optionNames


query.fromArgs = ->
  args = Array.from _.flattenDeep arguments
  # if not (args instanceof Array)
  #   args = [ args ]

  if args.length == 0
    return new Query()

  terms = []
  options = {}
  for arg in args
    if typeof arg == 'string'
      [key, value] = arg.split ':'
    else
      throw new Error "typeof arg #{typeof arg} is not a string"

    if not value?
      terms.push new RegExp key, 'i'
    else
      if optionNames.includes key
        if key == 'recurse' or key == 'depth'
          value = parseValue value
        options[key] = value
      else
        arg = {}
        arg[key] = new RegExp value, 'i'
        terms.push arg
  # log.debug 'query.fromArgs', {terms}
  new Query terms, options

module.exports = query
