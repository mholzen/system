query = require '../lib/query'
{createQuery, fromArgs, Query} = query
{post} = require '../lib'

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
      expect(q.match(false)).null
      expect(q.test(false)).be.false
      expect(q.test('foo')).be.true
      expect(q.test('bar')).be.true
      expect(q.test({a:1})).be.true

  describe 'from a function', ->
    it 'match', ->
      q = createQuery (v)-> if v == 'foo' then 'foo' else null
      expect(q.test('foo')).be.true
      expect(q.match('bar')).null
      expect(q.test('bar')).be.false
      expect(q.test('foobar')).be.false

    it 'and', ->
      q = createQuery (v)-> if v > 1 then v else null
      expect(q.test(1)).be.false
      expect(q.test(2)).be.true
      q = q.and createQuery (v)-> if v > 2 then v else null
      expect(q.test(2)).be.false
      expect(q.test(3)).be.true

  describe 'create from a string', ->
    it 'match a string', ->
      q = createQuery 'foo'
      expect(q.test('foo')).be.true
      expect(q.test('bar')).be.false
      expect(q.test('foobar')).be.false

    it.skip 'should avoid matching a string', ->
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
      expect(q.test({a:'foobar'})).be.false
      expect(q.test({a:'foo', b:'bar'})).be.true

  describe 'from an array', ->
    it 'should match a string', ->
      q = createQuery ['foo', 'bar']
      expect(q.test('foo bar')).be.false
      expect(q.test('bar')).be.false

    it 'should match an object and string', ->
      q = createQuery [{foo:/bar/}, /bing/]
      expect(q.test({foo:'bar', baz: 'bing'})).be.true
      expect(q.test({foo:'bar bing'})).be.true
      expect(q.test({foo:'bar'})).be.false

  describe 'from an object', ->
    it 'should match an object', ->
      q = createQuery {a: 'foo'}
      expect(q.test({a:'bar'})).be.false
      expect(q.test({a:'foo'})).be.true
      expect(q.test({b:'bing'})).be.false

  describe 'from another query', ->
    it 'should match an object', ->
      q = createQuery {a: 'foo'}
      q2 = createQuery q
      expect(q2.test({a:'bar'})).be.false
      expect(q2.test({a:'foo'})).be.true

  describe 'from an empty object', ->
    it 'should match an object', ->
      q = createQuery {}
      expect(q.test({a:'bar'})).be.false

  describe 'and', ->
    it 'should "and" with another query', ->
      q = createQuery /foo/
      q = q.and createQuery /bar/
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

  describe 'not matched', ->
    it '', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches 'foo'
      expect(nonMatches.test('bar')).be.true

    it 'with object', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches {a:'foo'}
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


describe 'query.test', ->
  it 'returns null with arrays and values', ->
    expect(query(1).test(2)).false
    expect(query([1,2]).test(3)).false
