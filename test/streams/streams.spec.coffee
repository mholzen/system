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
      stream.filter (x)-> x.stat.isFile()
      stream.map (x)-> mappers.content x, base: 'test/artifacts/small-directory'
      stream.flatMap stream
      # stream.doto log
      stream.map mappers.lines
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

  it 'one stream with one pipeline but `base` reference is duplicated', ->
    s = stream ['test/artifacts/small-directory']
    .through stream.pipeline(
      stream.flatMap generators.stats
      stream.filter (x)-> x.stat.isFile()
      stream.map (x)-> mappers.content x, base: 'test/artifacts/small-directory'
      stream.flatMap stream
      stream.map mappers.lines
      stream.map (x)-> x.filter (y)-> y.includes '1'
      stream.filter (x)-> x.length > 0
      stream.errors log.error
    )

    res = await collect s
    expect res
    .length 3

  builder = require 'streams/builder'

  it 'use a function that generates a second stream', ->
    s = stream ['test/artifacts/small-directory']

    onSecond = (f)->
      (data)->
        [data[0], f data[1]]

    # TODO: this could be a mapper
    lines = (base)->
      stream.pipeline(
        stream.filter mappers.isFile
        stream.map (x)-> mappers.content x, base: base
        stream.flatMap stream
        stream.map mappers.lines
        stream.map (x)-> x.filter (y)-> y.includes '1'
        stream.filter (x)-> x.length > 0
      )
    pipe = stream.pipeline(
      stream.map mappers.repeat   # TODO: base could be added to the context instead
      stream.map onSecond generators.stats
      stream.map (x)-> x[1].through lines x[0]
      stream.errors log.error
    )

    s = stream ['test/artifacts/small-directory']
    .through pipe

    res = await collect s
    res = await collect res[0]
    expect res
    .length 3


  it 'one pipeline that has a side effect of adding to a context', ->
    s = stream ['test/artifacts/small-directory']

    # TODO: this could be a mapper
    context = {}
    pipe = stream.pipeline(
      stream.doto (x)->context.base = x
      stream.flatMap generators.stats
      stream.filter (x)-> x.stat.isFile()
      stream.map (x)-> mappers.content x, context
      stream.flatMap stream
      stream.map mappers.lines
      stream.map (x)-> x.filter (y)-> y.includes '1'
      stream.filter (x)-> x.length > 0
      stream.errors log.error
    )

    s = stream ['test/artifacts/small-directory']
    .through pipe

    res = await collect s
    expect res
    .length 3


  it 'use augment on a context', ->
    s = stream ['test/artifacts/small-directory']

    # TODO: this could be a mapper
    lines = (base)->
      stream.pipeline(
        stream.map (x)->mappers.augment x, generators.stats, name:'stats'
        stream.filter mappers.isFile
        stream.map (x)-> mappers.content x, base: base
        stream.flatMap stream
        stream.map mappers.lines
        stream.map (x)-> x.filter (y)-> y.includes '1'
        stream.filter (x)-> x.length > 0
      )

    pipe = stream.pipeline(
      stream.map (x)->mappers.object x, 'base'

      stream.map (x)->mappers.augment x, ( (generators.stats(x.base)).through lines(x.base)), name:'lines'
      # stream.map (x)->mappers.augment x, ((stream([x.base])).through lines(x.base)), name:'lines'

      stream.errors (e)->log.error {e, stack: e.stack}
    )

    s = stream ['test/artifacts/small-directory']
    .through pipe
    .doto log

    res = await collect s
    log res
    l = await collect res[0].lines
    log l
    expect l
    .length 3


  it.skip 'use a builder to create the pipeline', ->
    pipe = builder(
      'flatMap,generators.stats'
      'filter,mappers.isFile'
      'map,mappers.content'
      'flatMap,mappers.stream'
      'map,mappers.lines'
      'map,mappers.filter,todo'
      'filter,mappers.hasLength'
      'errors,mappers.log'
    )

    s = stream ['test/artifacts/small-directory']
    .through pipe
    .doto log
    res = await collect s
    expect res
    .length 3

describe.skip 'save logs', ->
  describe.skip 'use streams to post to a directory to save ', ->
    it 'stream segment /files should use filesystem', ->
      s = builder 'test/artifacts/small-directory/apply/count'

    it 'post to a directory', ->
      mappers.post data, {type: 'directory'}

      s = builder 'test/artifacts/small-directory/apply/post,name:foo'
