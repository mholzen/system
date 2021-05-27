filepath = require 'lib/mappers/filepath'

describe 'filepath', ->
  it 'works', ->
    expect filepath 'a/b'
    .eql 'a/b'

    expect filepath ['a', 'b']
    .eql 'a/b'

  it 'use req.dirname', ->
    expect filepath 'a/b', {req: {dirname: 'r'}}
    .eql 'r/a/b'
