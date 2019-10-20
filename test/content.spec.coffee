{post, mappers: {content}} = require '../lib'
{searchers} = require '../lib'

require './searchers.spec.coffee'

{get} = content
describe 'content.get', ->
  it '', ->
    expect(get 1, []).eql 1
    a = await get {a:1}, ['a']
    expect(a).eql 1

describe 'content', ->
  it 'from:file', ->
    filename = await post 'foo'
    c = await content filename
    expect(c).equal 'foo'

  it 'from:path', ->
    c = await content {path:['a', 'b']}, root: {a:{b:1}}
    expect(c).eql 1
