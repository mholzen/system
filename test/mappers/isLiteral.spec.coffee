{isLiteral} = require '../../lib/mappers'

describe 'isLiteral', ->
  it 'works', ->
    expect isLiteral 0
    .eql true

    expect isLiteral {}
    .eql false
