{reducers} = require '../lib'

describe 'reducers', ->
  reduce = reducers.reduce

  it 'reduce', ->
    expect(reduce [1,1,1], 'count').eql 3