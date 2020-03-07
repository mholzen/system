pop = require '../lib/map/pop'

describe 'pop', ->
  it 'basic', ->
   expect(pop(['a'])).eql []
   expect(pop({path:['a', 'b']}, 'b')).eql path: ['a']
   expect(-> pop('foo')).throws()
   expect(-> pop()).throws()