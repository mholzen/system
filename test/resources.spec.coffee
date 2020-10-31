Resources = require  'lib/resources'

r = null
describe 'resources', ->
  beforeEach ->
    r = new Resources()
  it 'set key:array', ->
    r.set ['a'], 'data'

    expect r.get ['a']
    .eql 'data'

  it 'set key:array', ->
    r.set ['a', 'b'], 'data'

    expect r.get ['a']
    .instanceof Resources

    expect r.get(['a']).get ['b']
    .eql 'data'

  it 'set key:string', ->
    r = new Resources()
    r.set 'a', 'data'

    expect r.get 'a'
    .eql 'data'

  it 'set a/, b', ->
    r.set 'a/', 'data'
    expect r.get ['a']
    .eql 'data'
