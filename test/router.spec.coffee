router = require '../server/router'
get = router.get

r = new router.TreeRouter({})

f = (s, m1, m2)->
  m = s.match r.regexp
  expect(m[1]).equal m1
  expect(m[2]).equal m2

describe 'router', ->
  it 'should match parts', ->
    f '/', '', ''
    f '/foo', 'foo', ''
    f '/abc/foo', 'abc', '/foo'
    f 'abc', 'abc', ''
    f '', '', ''

describe 'get', ->
  context =
    a: 1
    b: (data)-> data.length
    c:
      a: 2

  it 'with no path should return data', ->
    r = await get 'abc'
    expect(r).equal 'abc'

  it 'with object and path returns that property of the object', ->
    r = await get(a:2, 'a')
    expect(r).equal 2

  it 'with a non-existing path in data should return context', ->
    r = await get('abc', 'a', context)
    expect(r).equal 1

  it.skip 'with a function name in data should return context', ->
    r = await get('abc', 'f', {f: (v)->v.length })
    expect(r).equal 3

  it 'with a function name in data should return context', ->
    r = await get('abc', 'c', context)
    expect(r).eql a: 2
