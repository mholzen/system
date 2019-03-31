query = require '../lib/query'
{createQuery, fromArgs, Query} = query
{post} = require '../lib'
# require './query.spec'

describe 'query', ->
  describe 'match', ->
    it 'from:empty', ->
      r = query().match 'abc'
      expect(r).eql ['abc']

    it 'match returns matches as property 0', ->
      r = query(1).match 1
      expect(r).eql [1]
      r = query('1').match 1
      expect(r).eql [1]
      r = query('a').match 'ab'
      expect(r).eql null
      r = query('a').match 'a'
      expect(r).eql ['a']
      r = query(1).match [1, 2, 1]
      expect(r).eql [1, 1]

      r = query(1).match {a:1, b:2, c:1}
      expect(r).eql [{a:1, c:1}]

      r = query(/[ac]/).match {a:1, b:2, c:1}
      expect(r).eql [{a:1, c:1}]

      r = query({a:1}).match {a:1, b:2, c:1}
      expect(r).property(0).eql {a:1}

      r = query({a:1}).match {a:1, b:2, c:{a:1}}
      expect(r).property('a').eql 1
      expect(r).property('c').eql {a:1}

    it 'matches returns matches and paths', ->
      r = query(1).matches 1
      expect(r.values).eql [1]
      r = query('a').matches 'ab'
      expect(r).eql null
      r = query('a').matches 'a'
      expect(r.values).eql ['a']
      r = query('a').matches ['a', 'b', 'a']
      expect(r).property(0).eql 'a'
      expect(r).property(2).eql 'a'

      r = query(/1/).matches 11
      expect(r).eql [11]

      r = query(/(a(b))/).matches 'abc'
      expect(r).eql [11]

      r = query(1).matches {a:1, b:2, c:1}
      expect(r).property('a').eql 1
      expect(r).property('c').eql 1

      r = query(/[ac]/).matches {a:1, b:2, c:1}
      expect(r).property('a').eql 1
      expect(r).property('c').eql 1

      r = query({a:1}).matches {a:1, b:2, c:1}
      expect(r).property('a').eql 1

      r = query({a:1}).matches {a:1, b:2, c:{a:1}}
      expect(r).property('a').eql 1
      expect(r).property('c').eql {a:1}


    it 'from:regexp', ->
      r = query(/1/).match 11
      expect(r).eql [11]
      r = query(/a/).match 'abc'
      expect(r).property(0).eql 'a'
      r = query(/a/).match ['a', 'b']
      expect(r).eql ['a']
      r = query(/a/).match {a:1, aa:2, b:1}
      expect(r).eql [{a:1, aa:2}]

    it 'array', ->
      r = await query([]).match 'abc'
      expect(r).eql ['abc']
      r = await query([/a.c/, /.b./]).match 'abc'
      expect(r).property(0).eql 'abc'
      r = await query([/a/, /d/]).match 'abc'
      expect(r).null
      r = await query([{a:1}, 2]).match {a:1}
      expect(r).null

  describe 'match', ->

    it 'array', ->
      r = await query(1).match [1, 2, 1]
      expect(r).eql [1,1]

    it 'object key', ->
      r = await query('a').match {a:1, b:2}
      expect(r).includes a:1

    it 'object value', ->
      r = await query(['john', 'doe']).match {first:'john', last:'doe'}
      expect(r).property(0).includes first:'john'
      expect(r).property(0).includes last:'doe'
      expect(r).property(1).includes first:'john'
      expect(r).property(2).includes last:'doe'

      r = await query(1).match {a:1, b:2}
      expect(r).property(0).eql {a:1}

    it 'query object with multiple keys must match all keys', ->
      r = await query({a:1, b:1}).match {a:1, b:1, c:1}
      expect(r).not.null

    it 'object query does not match anywhere in an object graph', ->
      r = await query(a:1).match b:{a:1}
      expect(r).null

    it 'an object query with recurse match anywhere in an object graph?', ->
      r = await query({a:1}, recurse:true).match b:{a:1}
      expect(r).not.null
      expect(r[0]).property('data').eql {a:1}
      expect(r[0]).property('path').eql ['b']

    it 'an object query with recurse should match multiple places in an object graph', ->
      q = query({a:1}, recurse:true)
      r = await q.match {b:{a:1}, c:{a:1}}
      expect(r).not.null

    it 'query object matches object in object graph', ->
      r = await query(['john', 'doe'], recurse:true).match {john:{first:'john', last:'doe'}}
      log r
      expect(r).property(0).includes first:'john'
      expect(r).property(0).includes last:'doe'
      expect(r).property(1).includes first:'john'
      expect(r).property(2).includes last:'doe'

      it 'test: query object with multiple key matches different objects in graph', ->
        r = await query({b:1, c:1}, recurse:true).match {a:{b:1}, c:1}
        # no: because it can be expressed with an array
        expect(r).null

        it 'no', ->
          r = await query([b:1, c:1], recurse:true).match {a:{b:1}, c:1}
          expect(r).not.null

    # it 'object with object', ->
    #   r = await query({a:1}).match {a:1, b:2}
    #   expect(r).property(0).eql 1
    #   expect(r).property('path').eql ['a']


  it.skip '-string on object key', ->
    # TODO: -a matches the value :1
    r = await query('-a').match {a:1, b:2}
    expect(r).eql b:2

  it.skip '-string on object value', ->
    # key 'a' matches '-1' so it returns it too
    r = await query('-1').match {a:'1', b:2}
    expect(r).eql b:2

# TODO: match against streams
