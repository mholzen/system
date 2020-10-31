{prepend} = require 'lib/mappers'

describe 'prepend', ->
  it 'works', ->
   expect(prepend(['a'], 'b')).eql ['b', 'a']
