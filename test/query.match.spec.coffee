query = require '../lib/query'
{createQuery, fromArgs, Query} = query
{post, stream} = require '../lib'
isPromise = require 'is-promise'

require './query.spec'

describe 'query', ->
  describe 'match', ->
    it 'from:empty', ->
      r = query().match 'abc'
      expect(r).eql [{value:'abc', path:[]}]

    it 'match fundamentals', ->
      r = query(1).match 1
      expect(r).eql [1]
      r = query('1').match 1
      expect(r).eql [1]
      r = query('a').match 'ab'
      expect(r).eql null
      r = query('a').match 'a'
      expect(r).eql ['a']
      expect query(1).match [1, 2, 1]
      .eql [
        {value: 1, path: [0]}
        {value: 1, path: [2]}
      ]

      expect query(/./).match 'abc'
      .eql [ value:'a', path: [0] ]

      # each key is a separate match
      r = query(1).match {a:1, b:2, c:1, d:{a:1}}
      expect(r).eql [
        {value: 1, path:['a']}
        {value: 1, path:['c']}
        {value: 1, path:['d', 'a']}
      ]

      expect(query('foo').match({a:{b:'foo', c:'bar'}})).eql [
        {value: 'foo', path: ['a', 'b']}
      ]

      r = query(/[ac]/).match {a:1, b:2, c:1}
      expect(r).eql [
        {value: {a:1}, path:[]}
        {value: {c:1}, path:[]}
      ]

      r = query(/[ac]/).match {i:[{a:1}, {b:2}, {c:1}]}
      expect(r).eql [
        {value: {a:1}, path:['i', 0]}
        {value: {c:1}, path:['i', 2]}
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
      expect(q.match({a:'abc'})).eql [
        {value: {a:'b'}, path: [{a: [1]}]}
      ]

      q = query {foo:/b/, bar:/a/}
      expect(q.match({foo:'abc', bar: 'abc'})).eql [
        {value: {foo:'b', bar:'a'}, path: [{foo: [1], bar: [0]}]}
      ]

    it 'from:array', ->
      r = query([]).match 'abc'
      expect(r).eql [{value:'abc', path:[]}]
      r = query([/a.c/, /.b./]).match 'abc'
      expect(r).eql [
        {value:'abc', path:[0]}
      ]

      r = query([/a/, /d/]).match 'abc'
      expect(r).null
      r = query([{a:1}, 2]).match {a:1}
      expect(r).null

      # r = query(['a', /b/]).match {c:{a:{e:'b'}}}
      # expect(r).eql []

      q = query [{a:/b/}, /abc/]
      # debug intersect a:[{value:{foo:b} path:[{foo:}]}] b:[{value:abc path:[foo,0]}]
      expect(q.match({a:'abc'})).eql [
        {value: 'b', path: [{a:[1]}]}
      ]

    it 'object match array', ->
      expect query(b:2).match([{a:1}, {b:2}, {c:3}])
      .eql [
        {value: {b:2}, path: [1]}
      ]
      expect(
        query(b:2).match([1,2,3])
      ).eql null

    it 'data:Stream', ->
      matches = query('b').match stream(['a', 'b', 'c'])
      expect(matches).property('0').property('value').satisfy stream.isStream
      results = await matches[0].value.toPromise Promise
      expect(results).eql 'b'

    it 'data:Promise', ->
      data = new Promise (resolve, reject)-> resolve ['a', 'b', 'c']
      expect(data).satisfy isPromise
      expect(data).property('then').a 'function'

      matches = query('b').match data
      expect(matches).property('0').property('value').respondTo 'then'
      results = await matches[0].value
      expect(results).eql [
        {value: 'b', path:[1]}
      ]

    it 'data:Map', ->
      data = new Map [['a', 1]]
      matches = query('a').match data
      expect(matches).property('0').eql {value:'a', path: [0,0]}


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

      it 'from string', ->
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

      it 'from object', ->
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

      it 'from regex', ->
        expect(query(/first|Marc/).match data).eql [
          {value:{first:'Marc'}, path:['mvh']}
          {value:'Marc', path:['mvh', 'first', 0]}
          {value:{first:'John'}, path:['jdoe']}
        ]

      it 'from object with regex', ->
        expect(query(first:/arc/).match data).eql [
          {value:{first:'arc'}, path:['mvh', {first:[1]}]}
        ]
        # TODO: problem above?  if path.length > nodes then it mean sindex
        # expect(query(first:/arc/).match data).eql [
        #   {value:{first:'arc'}, path:['mvh'], index: 1}
        # ]


      # TODO: doesn't work because mvh is top level
      it.skip 'from array', ->
        # joins each matches
        expect query([/a./,/.b/]).match ['a', 'b', 'ab']
        .eql [
          value: 'ab', path: [2]
        ]

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
