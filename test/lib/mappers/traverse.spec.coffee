{create} = require 'lib/mappers/traverse'

describe 'mappers/traverse', ->
  it 'works', ->
    traverse = create()
    expect traverse [1,2,3]
    .eql [
      # { value: [1,2,3], path: [] }
      {value:1, path:['0']}
      {value:2, path:['1']}
      {value:3, path:['2']}
    ]

  it 'no path', ->
    traverse = create noPath: true
    expect traverse [1,2,3]
    # .eql [[1, 2, 3]]
    .eql [1, 2, 3]
