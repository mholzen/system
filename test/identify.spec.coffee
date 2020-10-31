{identify} = require 'lib/mappers'

describe 'identify', ->
  it 'works', ->
    expect identify 1
    .eql 'Number'

    expect identify {a:1}
    .eql 'Object'

