{post, mappers: {content, augment, resolve}, searchers} = require 'lib'

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

  it 'from object', ->
    file = path: 'test/artifacts/3chars.txt'
    file = await resolve augment file, content
    expect file
    .property 'content'
    .eql Buffer.from 'abc'

  it.skip 'handles . for extension', ->
    file = path: 'test.artifacts.3chars.txt'
    file = await resolve augment file, content
    expect file
    .property 'content'
    .eql Buffer.from 'abc'
