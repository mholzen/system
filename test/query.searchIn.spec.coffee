query = require '../lib/query'
{post} = require '../lib'

describe 'query.searchIn', ->

  it 'should find in array', (done)->
    q = query 'foo', recurse:false
    o = q.searchIn ['bar', 'foo']
    o.toArray (results)->
      expect(results).eql ['foo']
      done()

  it 'should find in string', (done)->
    q = query 'line2', recurse:false
    o = q.searchIn 'line1\nline2\nline3'
    o.toArray (results)->
      expect(results).eql ['line2']
      done()

  it 'should find recursively in file', ->
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
