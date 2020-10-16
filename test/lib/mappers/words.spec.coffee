{words} = require '../../../lib/mappers'

describe 'words', ->
  it 'works', ->
    expect words 'a b c'
    .eql ['a', 'b', 'c']

    expect words 'a  b,  c.'
    .eql ['a', 'b', 'c']