{invert} = require 'lib/mappers'

describe 'isLiteral', ->
  it 'negate', ->
    f = (x)-> x == 'a'

    expect f 'a'
    .true

    expect f 'b'
    .false

    expect invert(f) 'a'
    .false

    expect invert(f) 'b'
    .true
