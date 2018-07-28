{createQuery, fromArgs, Query} = require '../lib/query'
{post} = require '../lib'

describe 'query', ()->
  describe 'from a boolean', ->
    it 'match', ->
      q = createQuery true
      expect(q.match(true)).be.true
      expect(q.match(false)).be.false
      expect(q.match('foo')).be.true
      expect(q.match('bar')).be.true
      expect(q.match({a:1})).be.true

  describe 'from a function', ->
    it 'match', ->
      q = createQuery (v)->v == 'foo'
      expect(q.match('foo')).be.true
      expect(q.match('bar')).be.false
      expect(q.match('foobar')).be.false

    it 'and', ->
      q = createQuery (v)->v > 1
      expect(q.match(1)).be.false
      expect(q.match(2)).be.true
      q = q.and createQuery (v)-> v > 2
      expect(q.match(2)).be.false
      expect(q.match(3)).be.true

  describe 'create from a string', ->
    it 'match a string', ->
      q = createQuery 'foo'
      expect(q.match('foo')).be.true
      expect(q.match('bar')).be.false
      expect(q.match('foobar')).be.true

    it 'should avoid matching a string', ->
      q = createQuery '-foo'
      expect(q.match('foobar')).be.false
      expect(q.match('baz')).be.true
      expect(q.match({bar: 'foo'})).be.false
      expect(q.match({baz: 'bin'})).be.true

      value = {foo: 'bar'}
      value.toString = -> this.foo
      expect(q.match(value)).be.true

    it 'should match an object', ->
      q = createQuery 'foo'
      expect(q.match({a:'bar'})).be.false
      expect(q.match({a:'foobar'})).be.true

  describe 'from an array', ->
    it 'should match a string', ->
      q = createQuery ['foo', 'bar']
      expect(q.match('foo bar')).be.true
      expect(q.match('bar')).be.false

    it 'should match an object and string', ->
      q = createQuery [{foo:'bar'}, 'bing']
      expect(q.match({foo:'bar', baz: 'bing'})).be.true
      expect(q.match({foo:'bar bing'})).be.true
      expect(q.match({foo:'bar'})).be.false

  describe 'from an object', ->
    it 'should match an object', ->
      q = createQuery {a: 'foo'}
      expect(q.match({a:'bar'})).be.false
      expect(q.match({a:'foo'})).be.true
      expect(q.match({b:'bing'})).be.false

    it 'should have object keys', ->
      q = createQuery {a: 'foo'}
      expect(q.model.a).instanceof Query

  describe 'from another query', ->
    it 'should match an object', ->
      q = createQuery {a: 'foo'}
      q2 = createQuery q
      expect(q2.match({a:'bar'})).be.false
      expect(q2.match({a:'foo'})).be.true

  describe 'from an empty object', ->
    it 'should match an object', ->
      q = createQuery {}
      expect(q.match({a:'bar'})).be.true
      expect(q.match({a:'foo'})).be.true

  describe 'and', ->
    it 'should "and" with another query', ->
      q = createQuery 'foo'
      q = q.and createQuery 'bar'
      expect(q.match('foo')).be.false
      expect(q.match('bar')).be.false
      expect(q.match('foobar')).be.true

  describe 'using in', ->
    it 'should match an object', ->
      # q = createQuery 'foo', {in:'bar'}
      # expect(q.match(bar: 'foo')).be.true
      # expect(q.match(bing: 'foo')).be.false
      # expect(q.match('foo')).be.true   # should technically be undefined

    it 'should match a file', ->
      q = createQuery 'foo', {in:'bar'}
      expect(q.match(
        type: 'file', name: 'foo', content: 'foo bar bing')
      ).be.true

    it 'should match a file', ->
      q = createQuery 'foo', {in:'bar'}
      expect(q.match(
        type: 'file', name: 'foo', content: 'foo bar bing')
      ).be.true

  describe 'matches', ->
    it '', ->
      q = createQuery 'foo'
      expect(q.matches).lengthOf(1)
      q = createQuery ['foo', 'bar']
      expect(q.matches).lengthOf(2)
      expect(q.toString()).equal('foo bar')

  describe 'not matched', ->
    it '', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches 'foo'
      expect(nonMatches.match('bar')).be.true
      expect(nonMatches.matches).lengthOf(1)

    it 'with object', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches {a:'foo'}
      expect(nonMatches.matches).lengthOf(1)
      expect(nonMatches.match('bar')).be.true

  describe 'using options', ->
    it '', ->
      q = createQuery 'foo', {limit: 1}
      expect(q.options.limit).equal(1)

  describe 'fromArgs', ()->
    it 'should match a key and value',->
      q = fromArgs 'foo:bar'
      expect(q.match({foo:'bar'})).be.true

    it 'should match an object and', ()->
      q = fromArgs ['foo:bar', 'google']
      expect(q.match({foo:'bar', bing:'google'})).be.true

    it 'should handle options', ()->
      q = fromArgs ['foo:bar', 'limit:1']
      expect(q.options.limit).equal(1)

  describe 'searchIn', ->
    it 'should find nonrecurse', (done)->
      q = createQuery 'foo', recurse:false
      o = q.searchIn ['bar', 'foo']
      o.toArray (results)->
        expect(results).eql ['foo']
        done()

    it 'should find recursively in file', ()->
      ref = await post("foo\nbar\nbing")
      expect(ref).startsWith '/'
      q = createQuery ['/', 'bar'], recurse:true
      expect(q.options.recurse).true
      o = q.searchIn [ref]
      o.toArray (results)->
        expect(results).eql ['bar']

  describe 'toString', ->
    it 'work', ->
      q = createQuery ['foo', 'bar']
      expect(q.toString()).not.includes '['
