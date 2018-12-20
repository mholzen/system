_ = require 'lodash'
log = require '@vonholzen/log'
# log = console.log
stream = require 'highland'
content = require './content'
parse = require './parse'
getContent = content
searchers = require './searchers'

class Query
  constructor: (query, options)->
    log 'query.constructor', {query, options}

    if query instanceof Query
      _.assign(this, query)
      return

    @options = options ? {}

    @options.recurse = options?.recurse ? true

    # @type = query.type ? options?.type

    if options?.limit?
      @options.limit = parseInt options.limit

    # refactor to setMatch
    @_match = query
    if typeof @_match == 'undefined'
      @_match = random

    if typeof @_match == 'boolean'
      bool = @_match
      @_match = (value)->
        log 'match.boolean', value
        if typeof value == 'boolean'
          value == bool
        else
          (typeof value != 'undefined') == bool

    if typeof @_match == 'string'
      @matches = [ @_match ]
      part = @_match
      @_match = (against)->
        if typeof against == 'object'
          against =
            if against.toString == Object.prototype.toString
              log 'query match: using JSON.stringify'
              JSON.stringify(against)
            else
              log 'query match: using object.toString'
              against.toString()

        if typeof against == 'string'
          return if part.startsWith '-'
            log 'match string avoid', {part: part}
            not against?.includes part.slice(1)
          else
            log 'match string match', {against, part}
            against?.includes part

        log 'query.match', "matching string against #{typeof against} returns undefined"
        return undefined
      return

    if typeof @_match == 'function'
      @matches = [ undefined ]
      return

    if @_match instanceof RegExp
      @matches = [ @_match ]
      regexp = @_match
      @_match = (against)-> regexp.test against
      return

    if @_match instanceof Array
      queries = @_match
      @matches = queries.map (query)-> new Query query

      log 'array', @_match
      @_match = (against) ->
        for query in @matches
          log 'array query match', {query, against}
          if not query.match against
            return false
        return true
      return

    if typeof @_match == 'object'
      @matches = [ @_match ]
      @model = @_match
      for key, value of @model
        @model[key] = new Query value

      @_match = (against)->
        for key, query of @model
          log 'object query match', {key, query, against}
          if not query.match against[key]
              return false
        return true

      return

  recurse: ->
    if typeof @options.recurse == 'boolean'
      return @options.recurse
    if typeof @options.recurse == 'number'
      return @options.recurse > 0

  match: (value)->
    @_match value

  isEmpty: ->
    @matches.length == 0

  nonMatches: (value)->
    new Query @matches.filter (match)->
      log 'query nonMatches', {match, value, result: not match.match value  }
      not match.match value

  and: (query)->
    new Query (value)=>
      @_match(value) and query.match(value)

  toJSON: -> {matches: @matches, options: @options}
  toString: ->
    return if @model?
      JSON.stringify @model
    else
      @matches?.join ' '

  searchIn: (resources, options)->
    options = options ? {}
    output = options.output ? stream()
    resources = resources ? searchers
    log 'searchIn start', {query: this, resources: resources, recurse: @recurse()}

    resources = if stream.isStream resources then resources else stream resources

    resultStreams = stream()
    mergedResults = resultStreams.merge()
    resultStreams.write output

    resources.each (resource)=>
      log 'searchIn new resource', {resource}
      match = @match resource
      if not @recurse()
        log 'searchIn recurse:false', {match}
        return if not match
        log 'searchIn writing result'
        return output.write resource

      unmetMatches = @nonMatches(resource)
      if typeof @options.recurse == 'number'
        unmetMatches.options.recurse = @options.recurse - 1

      log 'searchIn recurse:true', {match, unmetMatches: unmetMatches.toString() }
      if unmetMatches.isEmpty()
        # full match
        log 'searchIn writing result'
        return output.write resource


      log 'searchIn searching inside'
      try
        subResults = stream()
        resultStreams.write subResults

        # TODO: refactor to accept searchers
        if stream.isStream resource.items
          log 'searchIn reading from items stream', {name: resource?.name}
          parsedContent = resource.items
        else
          c = await getContent(resource)
          parsedContent = parse c    # refactor to accept stream
        log 'searchIn content', {c, parsedContent}

        unmetMatches.searchIn parsedContent, {output: subResults}
      catch error
        log 'searchIn error', {error}

    .done ->
      log 'searchIn done'
      output.end()
      resultStreams.end()

    return mergedResults



query = (terms, options)->
  new Query terms, options

query.Query = Query
query.createQuery = query

optionNames = [ 'duration', 'depth', 'limit', 'type', 'recurse' ]
query.optionNames = optionNames

parseValue = (value)->
  if value == 'true' or value == 'false'
    return (value == 'true')

  number = parseInt value
  if number != NaN
    return number

  value

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
