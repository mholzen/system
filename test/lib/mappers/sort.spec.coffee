{sort} = require 'lib/mappers'

describe 'sort', ->
  it 'works', ->
    expect sort [1,2,3]
    .eql [1, 2, 3]

  it 'uses score', ->
    expect sort [
      [1, 10]
      [2, 20]
      [3, 30]
    ]
    .eql [
      [3, 30]
      [2, 20]
      [1, 10]
    ]