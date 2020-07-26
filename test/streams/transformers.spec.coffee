{parse, map} = require '../../streams/transformers'    # units under tests

describe 'transformers', ->

  {stream, mappers} = require '../../lib'              # helpers (therefore depends on)

  it 'map', ->
    p =
    stream ['{"a":1}\n{"a":2}']
    .through parse()
    .collect().toPromise Promise

    p = await p
    expect(p).eql [{a:1}, {a:2}]

  it 'mappers.traverse', ->
    p = 
    stream [1,2,3]
    .through map mappers.traverse, {flat: true}
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2,3]

  it 'get:string', ->
    p =
    stream [{a:1}, {a:2}]
    .through map mappers.get, 'a'
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2]