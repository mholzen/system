stream = require '../lib/stream'

{sum} = require '../lib/mappers'

it 'should sum numbers', ->
  total = 0
  stream([1,2,3]).map sum()

  .toArray (a)->
    expect(a.length).equal 3
    expect(a[2]).equal 6

it 'should sum numbers as strings', ->
  total = 0
  stream(['1','2','3']).map sum()

  .toArray (a)->
    expect(a.length).equal 3
    expect(a[2]).equal 6
