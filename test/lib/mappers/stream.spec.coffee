{stream} = require '../../../lib/mappers'

describe 'stream', ->
  it 'works', ->
    expect stream "abc\ndef\nghi\n"
    .respondTo 'collect'
