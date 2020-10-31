{pop} = require 'lib/mappers'

describe 'pop', ->
  it 'works', ->
   expect(pop(['a'])).eql []
   expect(pop({path:['a', 'b']}, 'b')).eql path: ['a']