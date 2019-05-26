{query} = require '../lib/query'
{Match, intersect, startsWith} = require '../lib/match'

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

describe 'Match', ->
  it 'startswith', ->
    a = ['mvh', 'address']
    b = ['mvh', 'address', 'city']
    expect(startsWith(b,a)).true
    expect(startsWith(a,b)).false

  it 'and objects', ->
    a = new Match data.mvh.address, ['mvh', 'address']
    b = new Match data.mvh.address.city, ['mvh', 'address', 'city']
    expect(a.and b).eql b

    a = new Match {a:1}, []
    b = new Match 1, ['a']
    expect(intersect a, b).eql b
    expect(intersect b, a).eql b

    a = new Match {b:1}, []
    b = new Match 1, ['a']
    expect(intersect a, b).null
    expect(intersect b, a).null

  it 'and string', ->
    a = new Match 'abc', [0]
    b = new Match 'bc', [1]
    expect(intersect a, b).eql b
    expect(intersect b, a).eql b

    a = new Match 'ab', [0]
    b = new Match 'bc', [1]
    expect(intersect a, b).eql new Match 'b', [1]
    expect(intersect b, a).eql new Match 'b', [1]

    # d = {foo:'bar bing'}
    # [m1] = query({foo:/bar.*$/}).match d
    # [m2] = query(/bar bing/).match d
    # expect(intersect m1, m2).eql m1

    # expect(query(/a/).match('abc')).instanceof Matches
    # a = new Match data.mvh.address, ['mvh', 'address']
    # b = new Match data.mvh.address.city, ['mvh', 'address', 'city']
    #
    # expect(a.and b).eql b
    #
    # expect(intersect(a,b)).eql b

describe 'Matches', ->
  it 'intersect value', ->
    a = new Match 1, []
    b = new Match 1, []
    expect(intersect a,b).eql a

    a = new Match 1, []
    b = new Match 2, []
    expect(-> intersect a,b).throws()

    a = new Match {a:1}, []
    b = new Match {b:2}, []
    expect(intersect a,b).eql null

    a = new Match {a:1, c:3}, []
    b = new Match {b:2, c:3}, []
    expect(intersect a,b).eql new Match {c:3}, []

    a = new Match 1, ['a']
    b = new Match 2, ['b']
    expect(intersect a,b).eql null

    a = new Match 1, ['a']
    b = new Match 1, ['a']
    expect(intersect a,b).eql a

    a = new Match 1, ['a']
    b = new Match 2, ['a']
    expect(-> intersect a,b).throws()

    a = new Match {b:2}, ['a']
    b = new Match 2, ['a', 'b']
    expect(intersect a,b).eql b
    expect(intersect b,a).eql b

    a = new Match {c:3}, ['a']
    b = new Match 2, ['a', 'b']
    expect(intersect a,b).eql null
    expect(intersect b,a).eql null

    a = new Match 1, ['a', 'c']
    b = new Match 2, ['a', 'b']
    expect(intersect a,b).eql null
    expect(intersect b,a).eql null

  it 'intersect array and value', ->
    a = [new Match 1, ['a']]
    b = new Match 2, ['b']
    expect(intersect a, b).eql null
    expect(intersect b, a).eql null

    a = new Match {b:2, c:3}, ['a']
    b = [
      new Match 2, ['a', 'b']
      new Match 3, ['a', 'c']
    ]
    expect(intersect a, b).eql b
    expect(intersect b, a).eql b

  it 'intersect array and array', ->
    a = [new Match 1, ['a']]
    b = [new Match 1, ['a']]
    expect(intersect a, b).eql a

    # a = [
    #   new Match {a:1, b:2}, ['a']
    #   new Match {a:1, b:2}, ['b']
    # ]
    # b = [
    #   new Match 11, ['a', 'a']
    #   new Match 21, ['b', 'a']
    #   new Match 31, ['c', 'a']
    # ]
    # r = [
    #   new Match 11, ['a', 'a']
    #   new Match 21, ['b', 'a']
    # ]
    # expect(intersect a, b).eql r
    # expect(intersect b, a).eql r

  it 'intersect value and object', ->
    a = new Match {a:1}, []
    b = new Match 1, ['a']
    expect(intersect a, b).eql b
    expect(intersect b, a).eql b

  it 'intersect sub string', ->
    a = new Match 'abc', ['a', 0]
    b = new Match {a:'abc'}, []
    expect(intersect a, b).eql a
    expect(intersect b, a).eql a
