router = require '../server/router'

r = new router.TreeRouter()

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
