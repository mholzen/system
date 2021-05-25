{keys} = require  'streams/generators'

describe 'keys', ->
  it 'should work on string', ->
    expect -> keys 'abc'
    .throws()
