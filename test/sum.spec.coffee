{stream} = require '../lib'

{sum} = require '../lib/reducers'

describe 'sum', ->
  it 'from:numbers', ->
    r = await stream [1,2,3]
    .reduce1 sum()
    .toPromise Promise

    expect r
    .eql 6

  it 'from:strings', ->
    r = await stream ['1','2','3']
    .reduce1 sum()
    .toPromise Promise

    expect r
    .eql 6
