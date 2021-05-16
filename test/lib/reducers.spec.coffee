{reducers} = require 'lib'

requireDir = require 'require-dir'
requireDir './reducers'

describe 'reducers', ->
  reduce = reducers.reduce

  it 'reduce', ->
    expect(reduce [1,1,1], 'count').eql 3

fs = require 'fs'

describe.skip 'reduce to a map using any other command', ->
  it 'works with code', ->
    res = mappers.stream fs.createReadStream 'test/artifacts/names.csv'
    # .through system.streams.transformers.parse()
    # .reduce null, system.lib.reducers.map.create key: (x)->x[0]   # TODO: understand why {} are needed around the options
    .reduce null, reducers.map.create {key: (x)->x[0]}
    # .collect()
    .toPromise Promise
    res = await res
    log res

    expect res
    .length 5

  it 'streams', ->
    r = await mappers.stream [{a:1}, {a:2}, {b:3}]
    .reduce null, reducers.map.create {key: mappers.get.create 'a'}
    # NOTE: no need for collect if there's a single value in the stream
    .toPromise Promise

    expect r
    .respondTo 'entries'

    expect Array.from r.keys()
    .eql [1,2,undefined]

  it 'works with strings', ->
    res = pipe [
      ['literal', 'test/artifacts/names.csv']
      ['apply', 'stream']
      ['transform', 'parse']
      ['reduce', 'map', ['get', 'First'] ]
    ]

    expect res
    .length 5

  it 'content = file | parse', ->
    res = pipe [
      ['content', 'test/artifacts/names.csv']
      ['reduce', 'map', ['get', 'First'] ]
    ]

    expect res
    .length 5
