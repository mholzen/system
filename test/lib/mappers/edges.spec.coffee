edges = require 'lib/mappers/edges'

describe 'edges', ->
  it 'object', ->
    data =
      a: 1
      b: {b1: 1}
      c: 3
      d: ->

    expect edges data
    .eql ['b', 'd']

  it 'array', ->
    expect edges [1,2,3]
    .eql ['0','1','2']
