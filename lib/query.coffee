_ = require 'lodash'
log = require '@vonholzen/log'
# log = console.log
{stream, isStream} = require './stream'
content = require './content'
{parseValue} = require './parse'
getContent = content
{items} = require './generators'
iterable = require './map/iterable'

class Query
  setQuery: (query) ->
    @query = query
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
        @_match = @arrayMatch
      when typeof query == 'object'
        @_match = @objectMatch
      else
        throw new Error "unknown query type #{typeof query}"

  constructor: (query, options)->
    log 'query.constructor', {query, options}

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

  numberMatch: (data)->
    if typeof data == 'string'
      data = _.toNumber data

    if data instanceof Array
      return data.filter (d)=> @match d

    if typeof data == 'object'
      match = _.pickBy data, (v, k)=>
        (@query == v) or (@query == k)
      return if _.isEmpty match
        null
      else
        match

    if typeof data == 'number'
      return if @query == data
        data
      else
        null

    throw new Error "number query against '#{typeof data}' data"

  stringMatch: (data)->
    if typeof data == 'object'
      match = {}
      for key, value of data
        if @stringMatch key
          match[key] = value
          continue
        if (m = @stringMatch value)
          match.data = m[0]
          match.path = [key]
          continue

      if _.isEmpty match
        return null

      return match


    if ['number', 'boolean', 'symbol'].includes typeof data
      if data.toString() == @query
        return data
      else
        return null

    if typeof data == 'string'
      if @query.startsWith '-'
        return not data?.includes @query.slice(1)
      if data == @query
        return data
      return null

    if typeof data == 'function' or typeof data == 'undefined'
      return null

    throw new Error "string query against '#{typeof data}' data"

  regexpMatch: (data)->
    if ['number', 'boolean', 'symbol'].includes typeof data
      if @query.exec data.toString()
        return [data]
      else
        return null

    if typeof data == 'string'
      return @query.exec data

    if typeof data == 'object'
      matches = _.pickBy data, (v, k)=>
        @regexpMatch(v) or @regexpMatch(k)
      if _.isEmpty matches
        return null
      return [matches]

    throw new Error "regexp query against '#{typeof data}' data"


  _objectMatch: (data, matchFunction)->
    match = {}
    for key, value of @query
      if not (key of data)
        return null

      m = matchFunction key, value
      if m != null
        match[key] = m[0].data ? m[0]

    if _.isEmpty match
      return null

    return match


  objectMatch: (data)->
    if typeof data != 'object'
      throw new Error "cannot query object against '#{typeof data}' data"

    match = {}
    for key, value of @query
      if not (key of data)
        break
      valueMatch = query(value).match data[key]
      if valueMatch != null
        match[key] = valueMatch[0].data ? valueMatch[0]

    if not _.isEmpty match
      return [{
        data: match
        path: []
      }]

    if not @recurse()
      return null

    matches = []
    for key, value of data
      match = @match value
      if match != null
        m =
          data: match[0].data ? match[0]
          path: [key]
        if match[0].path?.length > 0
          m.path.push match[0].path
        matches.push m

    if matches.length == 0
      return null

    return matches


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

        return _.assign a, b
      throw new Error "adding '#{typeof a}' value neither object or string"

    matches.reduce (result, match)->
      add result, match

  arrayMatch: (data)->
    if @query.length == 0
      return [data]

    matches = []
    nullSeen = false
    for subquery in @query
      match = query(subquery).match data
      nullSeen = (match == null) or nullSeen
      matches.push match?[0]

    if not @options.partialMatches
      if nullSeen
        return null

    matches.unshift @_joinMatches matches
    matches

  test: (data)->
    return true if @query == null
    match = @_match data
    log 'query', {match}
    if match == null or match[0] == null
      return false
    true

  match: (data)->
    log 'query.match', {query: @query, data}

    if typeof data == 'undefined'
      return null

    if @query == null
      return [ data ]

    if data instanceof Array
      return data.filter (d) => @match d

    if stream.isStream data
      return data.filter @_match data

    match = @_match data
    if match == null
      return null

    if not [@arrayMatch, @regexpMatch, @objectMatch].includes @_match
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
    if not iterable data
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
        log 'query.search error', {error, e: error instanceof Error }
        throw error

    .done ->
      log 'query.search done'
      output.end()
      resultStreams.end()

    return mergedResults


  searchIn: (data, options)->
    if not iterable data
      try
        data = items data
        if data instanceof Promise
          log.debug 'here', data
      catch e
        log.error 'query', {e}
        return

    @search data, options


query = (terms, options)->
  new Query terms, options

query.Query = Query
query.createQuery = query

optionNames = [ 'duration', 'depth', 'limit', 'recurse' ]
query.optionNames = optionNames


query.fromArgs = ->
  args = Array.from _.flattenDeep arguments
  if not (args instanceof Array)
    args = [ args ]

  terms = []
  options = {}
  for arg in args
    if typeof arg == 'string'
      [key, value] = arg.split ':'
    else
      throw new Error "typeof arg #{typeof arg} is not a string"

    if not value?
      terms.push key
    else
      if optionNames.includes key
        if key == 'recurse' or key == 'depth'
          value = parseValue value
        options[key] = value
      else
        arg = {}
        arg[key] = new RegExp value, 'i'
        terms.push arg
  log 'query.fromArgs', {terms}
  new Query terms, options

module.exports = query
