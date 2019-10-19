{post, mappers: {content}} = require '../lib'
{searchers} = require '../lib'

require './searchers.spec.coffee'

describe 'content', ->
  it 'should get a file', ->
    filename = await post 'foo'
    c = await content filename
    expect(c).equal 'foo'

  it.skip 'from:path', ->
    c = content {path:[1]}, searchers()
    expect(c).eql 1
