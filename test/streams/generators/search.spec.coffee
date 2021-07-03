{create} = require 'streams/generators/search'

query = require  'lib/query'
{post} = require  'lib'

# TODO: should come before tests of 'bin/map'

describe 'generate/search', ->

  it 'should find in array of strings', (done)->
    generator = create query: query 'foo', recurse:false
    o = generator ['bar', 'foo']
    o.toArray (results)->
      expect(results).eql ['foo']
      done()

  it 'should find in array of numbers', (done)->
    generator = create query: query 2, recurse:false
    generator [1,2,3]
    .toArray (results)->
      expect(results).eql [2]
      done()

  it 'should find in objects', (done)->
    generator = create query: query {a:1}
    generator [{a:1, b:1, c:{d:1}}, {c:1}]
    .toArray (results)->
      expect(results).eql [value:{a:1}, path:[]]
      done()

  it.skip 'should find recursively in file', ->
    ref = await post("foo\nbar\nbing")
    expect(ref).startsWith '/'
    q = query [/\//, 'bar'], recurse:1
    expect(q.options.recurse).equal 1
    o = q.searchIn [ref]
    o.toArray (results)->
      expect(results).eql ['bar']

