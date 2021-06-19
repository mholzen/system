stream = require 'lib/stream'
generators = require  'streams/generators'

collect = (s)->
  s.collect().toPromise Promise

# Can we use streams to implement a request router

describe 'streams', ->
  it 'use mappers', ->
    s = stream [ 1, 'a' ]
    .map mappers.isLiteral

    expect await collect s
    .eql [ true, true ]

  it 'todos', ->
    s = generators.stats 'test/artifacts/small-directory'
    .through stream.pipeline(
      # stream.doto log
      stream.filter (x)-> x.value.isFile()
      stream.map (x)-> mappers.content x, base: 'test/artifacts/small-directory'
      stream.flatMap stream
      # stream.doto log
      stream.map mappers.lines  # could be through?
      # stream.doto log
      stream.map (x)-> x.filter (y)-> y.includes '1'
      stream.filter (x)-> x.length > 0
      # stream.doto log
      stream.errors (x)->
        log.error 'errors', {x}
    )

    res = await collect s

    expect res
    .length 3
