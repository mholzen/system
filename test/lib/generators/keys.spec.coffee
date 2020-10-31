{keys} = require  'lib/generators'

describe 'keys', ->
  it 'should work on string', ->
    expect(keys('abc')).undefined
