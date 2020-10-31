parse = require  'lib/parse'

{Readable} = require 'stream'

it 'should parse quoted csv', ->
  expect(parse('"a","b","c,d"')).eql ['a', 'b', 'c,d']

it 'should parse a json array', ->
  expect(parse('["a","b"]')).eql ['a', 'b']

it 'should parse a json object', ->
  expect(parse('{"a":"b"}')).eql {a: 'b'}

it 'should parse a stream', ->
  s = new Readable()
  s.push '"a","b","c,d"'
  s.push null
  out = parse s
  r = await out.toPromise Promise
  expect(r).eql ['a', 'b', 'c,d']
