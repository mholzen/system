traverse = require  'lib/iterators/traverse'
stream = require  'lib/mappers/stream'

describe 'stream traverse', ->
  it 'works', ->
    s = stream traverse [1,2,3]

    r = await s.collect().toPromise Promise
    expect r
    .log
    .eql [
      {value: 1, path: ['0']}
      {value: 2, path: ['1']}
      {value: 3, path: ['2']}
    ]
