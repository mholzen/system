{stream, map, mappers} = require '../lib'
describe 'map', ->

  it 'mappers.get', ->
    p =
    stream ['{"a":1}\n{"a":2}']
    .through map mappers.get.getter 'a'
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2]

  it 'mappers.traverse', ->
    p = 
    stream ["[1,2,3]"]
    .through map mappers.traverse, {flat: true}
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2,3]

  it 'get:string', ->
    p =
    stream ['{"a":1}\n{"a":2}']
    .through map 'get', 'a'
    .collect().toPromise Promise

    p = await p
    expect(p).eql [1,2]
