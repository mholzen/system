_ = require 'lodash'
log = require '@vonholzen/log'
# log = console.log
stream = require './stream'
content = require './content'
{parseValue} = require './parse'
getContent = content
{items} = require './generators'

class Query
  setQuery: (query) ->
    @query = query
    switch
      when query instanceof Query
        _.assign(this, query)
      when typeof query == 'undefined'
        @_match = (data)->data
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

    @options.recurse ?= true
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
      data == @query
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
      matches = _.pickBy data, (v, k)=>
        # recurses into v if v is Class
        @stringMatch(v) or @stringMatch(k)
      if _.isEmpty matches
        return null
      return matches

    if ['number', 'boolean'].includes typeof data
      data = data.toString()

    if typeof data == 'string'
      if @query.startsWith '-'
        return not data?.includes @query.slice(1)
      if data == @query
        return @query
      return null

    if typeof data == 'function' or typeof data == 'undefined'
      return null

    throw new Error "string query against '#{typeof data}' data"

  regexpMatch: (data)->
    if typeof data == 'string'
      return @query.exec data

    if typeof data == 'object'
      matches = _.pickBy data, (v, k)=>
        @regexpMatch(v) or @regexpMatch(k)
      if _.isEmpty matches
        return null
      return matches

    throw new Error "regexp query against '#{typeof data}' data"

  objectMatch: (data)->
    if typeof data != 'object'
      throw new Error "cannot query object against '#{typeof data}' data"

    matches = {}
    for key, value of @query
      if not (key of data)
        continue
      match = query(value).match data[key]

      if match != null
        matches[key] = match

    if _.isEmpty matches
      return null
    return matches

  joinMatches: (matches)->
    isRegeExpAnswer = (a)->
      typeof a?[0] == 'string' and
      typeof a?.index == 'number' and
      typeof a?.input == 'string'

    add = (a,b)->
      if typeof a == 'string'
        return a+b

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
      return data

    matches = []
    nullSeen = false
    for subquery in @query
      match = query(subquery).match data
      matches.push match
      nullSeen = (match == null) or nullSeen

    if not @options.partialMatches
      if nullSeen
        return null


    matches.unshift @joinMatches matches
    matches

  test: (data)->
    return true if @query == null
    match = @_match data
    log.debug {match}
    return true if match == true
    return undefined if typeof match == 'undefined'
    return not _.isEmpty match

  match: (data)->
    if typeof data == 'undefined'
      return undefined

    return data if @query == null

    if data instanceof Array
      return data.filter (d) => @match d

    if stream.isStream data
      return data.filter @_match data

    @_match data

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
      @_match(value) and query.test(value)

  toJSON: -> {matches: @matches, options: @options}

  toString: ->
    return if @model?
      JSON.stringify @model
    else
      @matches?.join ' '

  searchIn: (resources, options)->
    options = options ? {}
    output = options.output ? stream()

    log 'query.searchIn start', {query: this, 'typeof resource': typeof resources}

    resources = items resources

    # if typeof resources == 'undefined'
    #   return stream([])

    # if not stream.isStream resources
    #   if typeof resources[Symbol.iterator] != 'function'
    #     resources = [ resources ]
    #   resources = stream resources

    resultStreams = stream()
    mergedResults = resultStreams.merge()
    resultStreams.write output

    resources.each (resource)=>

      if not @recurse()
        log 'query.searchIn not recursing', {recurse: @recurse()}

        if @test resource
          log 'query.searchIn writing ', {resource}
          output.write resource

        return

      log 'query.searchIn recursing', {recurse: @recurse()}

      unmetMatches = @nonMatches resource
      # TODO: consider if unmetMatches is empty
      # write this resource and don't search into it

      if typeof @options.recurse == 'number'
        unmetMatches.options.recurse = @options.recurse - 1

      log 'query.searchIn', {unmetMatches}

      try
        subResults = stream()
        resultStreams.write subResults

        data = await getContent resource
        log 'query.searchIn getContent', {data}

        unmetMatches.searchIn data, {output: subResults}
      catch error
        log 'query.searchIn error', {error, e: error instanceof Error }
        throw error

    .done ->
      log 'query.searchIn done'
      output.end()
      resultStreams.end()

    return mergedResults



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

  new Query terms, options

module.exports = query
