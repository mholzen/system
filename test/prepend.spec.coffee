prepend = require '../lib/map/prepend'

describe 'prepend', ->
  it 'basic', ->
   expect(prepend(['a'], 'b')).eql ['b', 'a']
   expect(prepend({path:['a']}, 'b')).eql path: ['b', 'a']
   expect(-> prepend('foo')).throws()
   expect(-> prepend()).throws()