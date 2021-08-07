path = require 'lib/mappers/path'

describe 'path', ->
  it 'finds partial path', ->

    p = path ['a', 'b'], {a:{b:{c:1}}}
    expect p.to
    .eql {c:1}
