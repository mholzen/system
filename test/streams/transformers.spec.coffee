require  'lib/index'

{parse, map, notnull} = require '../../streams/transformers'    # units under tests

describe 'transformers', ->

  {stream, mappers} = require  'lib'              # helpers (therefore depends on)

  it 'map', ->
    p =
    stream ['{"a":1}\n{"a":2}']
    .through parse()
    .collect().toPromise Promise

    p = await p
    expect(p).eql [{a:1}, {a:2}]

  it 'mappers.traverse', ->
    mapper = mappers 'traverse'
    p = 
    stream [1,2,3]
    .through map mapper, {flat: true}
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2,3]

  it 'get:string', ->
    mapper = mappers 'get', 'a'
    p =
    stream [{a:1}, {a:2}]
    .through map mapper
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2]

  it 'get:string', ->
    mapper = mappers 'get', 'a'
    p =
    stream [{a:1}, {a:2}]
    .through map mapper
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2]

  it 'notnull', ->
    stream([1, null, undefined, 2])
    .through notnull