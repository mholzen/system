query = require '../lib/query'
{createQuery, fromArgs, Query, ObjectQuery} = query
{post} = require '../lib'

describe 'ObjectQuery', ->
  it 'matches', ->
    q = new ObjectQuery a: 'foo'
    expect(q.matches({a:'foo', b:'bar'})).eql a:'foo'

describe 'query', ->
  describe 'from null', ->
    it 'match always', ->
      q = createQuery null
      expect(q.test(null)).be.true
      expect(q.test(true)).be.true
      expect(q.test(false)).be.true
      expect(q.test(0)).be.true
      expect(q.test('bar')).be.true
      expect(q.test({a:1})).be.true

  describe 'from a boolean', ->
    it 'match', ->
      q = createQuery true
      expect(q.test(true)).be.true
      expect(q.test(false)).be.false
      expect(q.test('foo')).be.true
      expect(q.test('bar')).be.true
      expect(q.test({a:1})).be.true

  describe 'from a function', ->
    it 'match', ->
      q = createQuery (v)->v == 'foo'
      expect(q.test('foo')).be.true
      expect(q.test('bar')).be.false
      expect(q.test('foobar')).be.false

    it 'and', ->
      q = createQuery (v)->v > 1
      expect(q.test(1)).be.false
      expect(q.test(2)).be.true
      q = q.and createQuery (v)-> v > 2
      expect(q.test(2)).be.false
      expect(q.test(3)).be.true

  describe 'create from a string', ->
    it 'match a string', ->
      q = createQuery 'foo'
      expect(q.test('foo')).be.true
      expect(q.test('bar')).be.false
      expect(q.test('foobar')).be.true

    it 'should avoid matching a string', ->
      q = createQuery '-foo'
      expect(q.test('foobar')).be.false
      expect(q.test('baz')).be.true
      expect(q.test({bar: 'foo'})).be.false
      expect(q.test({baz: 'bin'})).be.true

      value = {foo: 'bar'}
      value.toString = -> this.foo
      expect(q.test(value)).be.true

    it 'should match an object', ->
      q = createQuery 'foo'
      expect(q.test({a:'bar'})).be.false
      expect(q.test({a:'foobar'})).be.true
      expect(q.test({a:'foo', b:'bar'})).be.true

  describe 'from an array', ->
    it 'should match a string', ->
      q = createQuery ['foo', 'bar']
      expect(q.test('foo bar')).be.true
      expect(q.test('bar')).be.false

    it 'should match an object and string', ->
      q = createQuery [{foo:'bar'}, 'bing']
      expect(q.test({foo:'bar', baz: 'bing'})).be.true
      expect(q.test({foo:'bar bing'})).be.true
      expect(q.test({foo:'bar'})).be.false

  describe 'from an object', ->
    it 'should match an object', ->
      q = createQuery {a: 'foo'}
      expect(q.test({a:'bar'})).be.false
      expect(q.test({a:'foo'})).be.true
      expect(q.test({b:'bing'})).be.false

    it 'should have object keys', ->
      q = createQuery {a: 'foo'}
      expect(q.model.a).instanceof Query

  describe 'from another query', ->
    it 'should match an object', ->
      q = createQuery {a: 'foo'}
      q2 = createQuery q
      expect(q2.test({a:'bar'})).be.false
      expect(q2.test({a:'foo'})).be.true

  describe 'from an empty object', ->
    it 'should match an object', ->
      q = createQuery {}
      expect(q.test({a:'bar'})).be.true
      expect(q.test({a:'foo'})).be.true

  describe 'and', ->
    it 'should "and" with another query', ->
      q = createQuery 'foo'
      q = q.and createQuery 'bar'
      expect(q.test('foo')).be.false
      expect(q.test('bar')).be.false
      expect(q.test('foobar')).be.true

  describe 'using in', ->
    it 'should match an object', ->
      # q = createQuery 'foo', {in:'bar'}
      # expect(q.test(bar: 'foo')).be.true
      # expect(q.test(bing: 'foo')).be.false
      # expect(q.test('foo')).be.true   # should technically be undefined

    it 'should match a file', ->
      q = createQuery 'foo', {in:'bar'}
      expect(q.test(
        type: 'file', name: 'foo', content: 'foo bar bing')
      ).be.true

    it 'should match a file', ->
      q = createQuery 'foo', {in:'bar'}
      expect(q.test(
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
      expect(nonMatches.test('bar')).be.true
      expect(nonMatches.matches).lengthOf(1)

    it 'with object', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches {a:'foo'}
      expect(nonMatches.matches).lengthOf(1)
      expect(nonMatches.test('bar')).be.true

  describe 'using options', ->
    it '', ->
      q = createQuery 'foo', {limit: 1}
      expect(q.options.limit).equal(1)

  describe 'fromArgs', ()->
    it 'should match a key and value',->
      q = fromArgs 'foo:bar'
      expect(q.test({foo:'bar'})).be.true

    it 'should match an object and', ()->
      q = fromArgs ['foo:bar', 'google']
      expect(q.test({foo:'bar', bing:'google'})).be.true

    it 'should handle options', ()->
      q = fromArgs ['foo:bar', 'limit:1', 'recurse:2']
      expect(q.options.limit).equal(1)
      expect(q.options.recurse).equal(2)

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

    it 'should search in nothing', (done)->
      q = createQuery 'abc'
      o = q.searchIn()          # TODO: does not return
      o.toArray (results)->
        expect(results.length).eql 0
        done()


  describe 'toString', ->
    it 'work', ->
      q = createQuery ['foo', 'bar']
      expect(q.toString()).not.includes '['
