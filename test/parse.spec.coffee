parse = require '../lib/parse'

it 'should parse quoted csv', ->
  expect(parse('"a","b","a,b"')).eql ['a', 'b', 'a,b']
