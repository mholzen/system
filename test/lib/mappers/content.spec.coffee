{post, mappers: {content}, searchers} = require 'lib'

require '../../searchers.spec.coffee'

{get} = content
describe 'content.get', ->
  it 'works', ->
    expect(get 1, []).eql 1
    a = await get {a:1}, ['a']
    expect(a).eql 1

describe 'content', ->
  it 'from:file', ->
    filename = await post 'foo'
    c = await content filename
    r = new Buffer(3)
    r.asciiWrite 'foo'
    expect(c).eql r
