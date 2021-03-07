{query, stream} = require  'lib/'
{Match} = require  'lib/match'
{createQuery, fromArgs, Query} = query
{post} = require  'lib'
isPromise = require 'is-promise'

require './results.spec'

describe 'query', ->
  describe '.match', ->
    it 'from:empty', ->
      r = query().match 'abc'
      expect(r).eql [{value:'abc', path:[]}]

    it 'data:Map', ->
      r = query('a')._objectMatchMap new Map Object.entries {k: 'a'}
      expect(r).eql [
        {value: 'a', path: ['k']}
      ]

      r = query('k')._objectMatchMap new Map Object.entries {k: 'a'}
      expect(r).eql [
        {value: ['k', 'a'], path: []}
      ]

      r = query('a').match new Map Object.entries {k: 'a'}
      expect(r).eql [
        {value: 'a', path: ['k']}
      ]

      r = query('k').match new Map Object.entries {k: 'a'}
      expect(r).eql [
        {value: ['k', 'a'], path: []}
      ]

    it 'fundamentals', ->
      r = query(1).match 1
      expect(r).eql [1]

      r = query(1).match 2
      expect(r).eql null

      r = query('1').match 1
      expect(r).eql [1]
      r = query('a').match 'ab'
      expect(r).eql null
      r = query('a').match 'a'
      expect(r).eql ['a']
      
      expect query(1).test []
      .eql false

      expect query(1).match [1, 2, 1]
      .eql [
        {value: 1, path: [0]}
        {value: 1, path: [2]}
      ]
      expect(query(null).match(null)).eql [value: null, path:[]]
      expect(query(1).match(null)).eql null

      expect query(/./).match 'abc'
      .eql [ value:'a', path: [0] ]

      # each key is a separate match
      r = query(1).match {d:{a:1}}
      expect(r).eql [
        {value: 1, path:['d', 'a']}
      ]

      r = query(1).match {a:1, b:2, c:1, d:{a:1}}
      expect(r).eql [
        {value: 1, path:['a']}
        {value: 1, path:['c']}
        {value: 1, path:['d', 'a']}
      ]

      expect(query('foo').match({a:{b:'foo', c:'bar'}})).eql [
        {value: 'foo', path: ['a', 'b']}
      ]

      expect(query('foo').match({foo:1})).eql [
        {value: {foo:1}, path: []}
      ]

      r = query(/[ac]/).match {a:1, b:2, c:1}
      expect(r).eql [
        {value: {a:1}, path:[]}
        {value: {c:1}, path:[]}
      ]

      r = query(/[ac]/).match {k:[{a:1}, {b:2}, {c:1}]}
      expect(r).eql [
        {value: {a:1}, path:['k', 0]}
        {value: {c:1}, path:['k', 2]}
      ]

      r = query({a:1}).match {a:1, b:2, c:1}
      expect(r).eql [{value:{a:1}, path:[]}]

      r = query({a:1}).match {a:1, b:2, c:{a:1}}
      # TODO: dependency on order
      expect(r).eql [
        {value:{a:1}, path:['c']}
        {value:{a:1}, path:[]}
      ]

      r = query({a:/a/, b:/b/}).match {a:'abc', b:'abc'}
      expect(r).eql [
        { value:{a:'a', b:'b'}, path:[{a:[0], b:[1]}] }
      ]

    it 'from:regexp', ->
      r = query(/1/).match 11
      expect(r).eql [11]

      r = query(/a/).match 'abc'
      expect(r).eql [value:'a', path:[0]]

      r = query(/a/).match ['a', 'b']
      expect(r).eql [
        {value:'a', path: [0,0]}
      ]

      r = query(/a/).match {a:1, aa:2, b:1}
      expect(r).eql [
        {value:{a:1}, path: []}
        {value:{aa:2}, path: []}
      ]

    it.skip 'regexp global', ->
      r = query(/a/g).match 'abca'
      expect(r).eql [{value:'a', path:[0]}, {value:'a', path:[3]}]

    it 'from:object', ->
      expect(query({b:1}).match({a:1})).null
      q = query {a:1}
      expect(q.match({a:1})).eql [
        {value: {a:1}, path: []}
      ]

      q = query {foo:/b/, bar:/a/}
      expect(q.match({foo:'abc', bar: 'abc'})).eql [
        {value: {foo:'b', bar:'a'}, path: [{foo: [1], bar: [0]}]}
      ]

    it 'from:object with regexp', ->
      q = query [{a:/b/}]
      r = q.match {a:'abc'}
      expect(r).eql [
        {value: {a:'b'}, path: [{a: [1]}]}
      ]

      q = query {foo:/b/, bar:/a/}
      expect(q.match({foo:'abc', bar: 'abc'})).eql [
        {value: {foo:'b', bar:'a'}, path: [{foo: [1], bar: [0]}]}
      ]

    it 'from:array', ->
      r = query([]).match 'abc'
      expect(r).eql [{value:'abc', path:[]}]

      r = query([1, 1]).match 1
      expect(r).eql [
        {value: 1, path:[]}
      ]

      r = query([/a.c/, /.b./]).match 'abc'
      expect(r).eql [
        {value:'abc', path:[0,0]}
      ]

      r = query([/a/, /d/]).match 'abc'
      expect(r).null
      r = query([{a:1}, 2]).match {a:1}
      expect(r).null

      # r = query(['a', /b/]).match {c:{a:{e:'b'}}}
      # expect(r).eql []

      q = query [{a:/abc/}, /b/]
      # debug intersect a:[{value:{foo:b} path:[{foo:}]}] b:[{value:abc path:[foo,0]}]

      r = q.match {a:'abc'}
      expect(r).eql [
        {value: 'b', path: [{a:[0]}, 'a', 1]}
      ]

    it 'object match array', ->
      expect query(b:2).match([{a:1}, {b:2}, {c:3}])
      .eql [
        {value: {b:2}, path: [1]}
      ]
      expect(
        query(b:2).match([1,2,3])
      ).eql null

    it 'data:Match', ->
      data = new Match 'a', ['b']
      matches = query(/a/).match data
      expect(matches).property('0').eql value: 'a', path:['b', 0]

    it 'data:Stream', ->
      matches = query('b').match stream ['a', 'b', 'c']
      expect(matches).satisfy stream.isStream
      results = await matches.collect().toPromise Promise
      expect(results).eql ['b']

    it 'data:Promise', ->
      data = new Promise (resolve, reject)-> resolve ['a', 'b', 'c']
      expect(data).satisfy isPromise
      expect(data).property('then').a 'function'

      matches = query('b').match data
      # log.debug {matches}
      expect(matches).satisfy isPromise
      results = await matches
      expect(results).eql [
        {value: 'b', path:[1]}
      ]

    it 'data:{k:Promise}', ->
      data = new Promise (resolve, reject)-> resolve ['a', 'b', 'c']
      r = query('b').match {k: data}
      # log.debug {r}
      r = await Promise.all r
      r = r.flat()

      expect(r).property('0').property('path').eql ['k']
      expect(r).property('0').property('value').satisfy isPromise

    it 'data:Map', ->
      data = new Map [['a', 1]]
      matches = query('a').match data
      expect(matches).property('0').eql {value: ['a',1], path: []}

    describe 'high level', ->
      describe 'matches object', ->
        data =
          mvh:
            first: 'Marc'
            last: 'von Holzen'
            address:
              street: '6703 34th Ave NW'
              city: 'Seattle'
            accounts:
              checking:
                wellsfargo: 123
          jdoe:
            first: 'John'
            last: 'Doe'
            address:
              street: 'Avenue A'
              city: 'Seattle'

        it 'from:string', ->
          expect(query('mvh').match data).eql [
            {value:{mvh:data.mvh}, path:[]}
          ]
          expect(query('last').match data).eql [
            {value:{last:'von Holzen'}, path:['mvh']}
            {value:{last:'Doe'}, path:['jdoe']}
          ]
          expect(query('Seattle').match data).eql [
            {value:'Seattle', path:['mvh', 'address', 'city']}
            {value:'Seattle', path:['jdoe', 'address', 'city']}
          ]
          expect(query('wellsfargo').match data).eql [
            {value:{wellsfargo: 123}, path:['mvh', 'accounts', 'checking']}
          ]

        it 'from:object', ->
          q = query first: 'Marc'
          expect(q.match(data.mvh)).eql [
            value:{first:'Marc'}, path: []
          ]

          expect(q.match(data)).eql [
            value:{first:'Marc'}, path: ['mvh']
          ]

          expect(query(city: 'Seattle').match(data)).eql [
            {value:{city: 'Seattle'}, path: ['mvh', 'address']}
            {value:{city: 'Seattle'}, path: ['jdoe', 'address']}
            # TODO: order is not guaranteed
          ]

        it 'from:regex', ->
          expect(query(/first|Marc/).match data).eql [
            {value:{first:'Marc'}, path:['mvh']}
            {value:'Marc', path:['mvh', 'first', 0]}
            {value:{first:'John'}, path:['jdoe']}
          ]

        it 'from:object with regex', ->
          expect(query(first:/arc/).match data).eql [
            {value:{first:'arc'}, path:['mvh', {first:[1]}]}
          ]
          # TODO: problem above?  if path.length > nodes then it mean sindex
          # expect(query(first:/arc/).match data).eql [
          #   {value:{first:'arc'}, path:['mvh'], index: 1}
          # ]

        it 'from array', ->
          # joins each matches
          expect(query([
            'mvh'
            'address'
          ]).match data)
          .eql [
            value: {address: data.mvh.address}
            path: ['mvh']
          ]

        # array = [data.mvh, data.jdoe]
        # expect(query('marc').match array).eql ['marc']
        # expect(query('marc').match array).eql [
        #   {value:'marc', path:['0', 'first']}
        # ]

        # expect(query('marc').match data).eql ['marc']
        # expect(query('mvh').match data).eql [{mvh: data.mvh}]

  describe '.test', ->
    describe 'from:null', ->
      it 'match always', ->
        q = createQuery null
        expect(q.test(null)).be.true
        expect(q.test(true)).be.true
        expect(q.test(false)).be.true
        expect(q.test(0)).be.true
        expect(q.test('bar')).be.true
        expect(q.test({a:1})).be.true

    describe 'from:boolean', ->
      it 'match', ->
        q = createQuery true
        expect(q.test(true)).be.true
        expect(q.match(false)).null
        expect(q.test(false)).be.false
        expect(q.test('foo')).be.true
        expect(q.test('bar')).be.true
        expect(q.test({a:1})).be.true

      it 'a promise', ->
        p = new Promise (resolve)->resolve 1
        expect(await query(2).test(p))
        .eql false

    describe 'from:function', ->
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

    describe 'from:string', ->
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

      it 'match:object', ->
        q = query 'foo'
        expect(q.test({a:'bar'})).be.false
        expect(q.test({a:'foobar'})).be.false
        expect(q.test({a:'foo', b:'bar'})).be.true
        expect(q.test({b:{a:'foo', b:'bar'}})).be.true

    describe 'from:regex', ->
      it 'match a string', ->
        expect query(/./).match 'abc'
        .eql [value: 'a', path: [0]]

        expect query(/b/).match 'abc'
        .eql [value: 'b', path: [1]]

    describe 'from:array', ->
      it 'should match a string', ->
        q = createQuery ['foo', 'bar']
        expect(q.test('foo bar')).be.false
        expect(q.test('bar')).be.false

      it 'should match an object and string', ->
        q = createQuery [{foo:/bar/}, /bing/]
        expect(q.test({foo:'bar', baz: 'bing'})).be.false
        expect(q.test({foo:'bar bing'})).be.false
        expect(q.test({foo:'bar'})).be.false

    describe 'from:object', ->
      it 'should match an object', ->
        q = createQuery {a: 'foo'}
        expect(q.test({a:'bar'})).be.false
        expect(q.test({a:'foo'})).be.true
        expect(q.test({b:'bing'})).be.false

    describe 'from:query', ->
      it 'should match an object', ->
        q = createQuery {a: 'foo'}
        q2 = createQuery q
        expect(q2.test({a:'bar'})).be.false
        expect(q2.test({a:'foo'})).be.true

    describe 'from:empty object', ->
      it 'should match an object', ->
        q = createQuery {}
        expect(q.test({a:'bar'})).be.false

    it 'returns null with arrays and values', ->
      expect(query(1).test(2)).false
      expect(query([1,2]).test(3)).false

  describe '.and', ->
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

  describe '.nonMatches', ->
    it '', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches 'foo'
      expect(nonMatches.test('bar')).be.true

    it 'with object', ->
      q = createQuery ['foo', 'bar']
      nonMatches = q.nonMatches {a:'foo'}
      expect(nonMatches.test('bar')).be.true

  describe 'using options', ->
    it 'limit', ->
      q = createQuery 'foo', {limit: 1}
      expect(q.options.limit).equal(1)

  describe 'fromArgs', ()->
    it 'nothing',->
      q = fromArgs()
      expect(q.query).be.null

    it 'empty array',->
      q = fromArgs []
      expect(q.query).be.null

    it 'should match a key and value',->
      q = fromArgs 'foo:bar'
      expect(q.test({foo:'bar'})).be.true

    it 'should handle options', ()->
      q = fromArgs ['foo:bar', 'limit:1', 'recurse:2']
      expect(q.options.limit).equal(1)
      expect(q.options.recurse).equal(2)
      expect(q.recurse()).true

