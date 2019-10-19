{post, mappers: {content}} = require '../lib'
{searchers} = require '../lib'

require './searchers.spec.coffee'

describe 'content', ->
  it 'from:file', ->
    filename = await post 'foo'
    c = await content filename
    expect(c).equal 'foo'

  it 'from:path', ->
    c = content {path:['a', 'b']}, {a:{b:1}}
    expect(c).eql 1
