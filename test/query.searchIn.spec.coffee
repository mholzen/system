query = require '../lib/query'
{post} = require '../lib'

describe 'query.searchIn', ->

  it 'should find in array of strings', (done)->
    q = query 'foo', recurse:false
    o = q.searchIn ['bar', 'foo']
    o.toArray (results)->
      expect(results).eql ['foo']
      done()

  it 'should find in array of numbers', (done)->
    q = query 2, recurse:false
    o = q.searchIn [1,2,3]
    o.toArray (results)->
      expect(results).eql [2]
      done()

  it.skip 'should find recursively in file', ->
    ref = await post("foo\nbar\nbing")
    expect(ref).startsWith '/'
    q = query [/\//, 'bar'], recurse:1
    expect(q.options.recurse).equal 1
    o = q.searchIn [ref]
    o.toArray (results)->
      expect(results).eql ['bar']

  it 'should search in nothing', (done)->
    q = query 'abc'
    o = q.searchIn()          # TODO: does not return
    o.toArray (results)->
      expect(results.length).eql 0
      done()
