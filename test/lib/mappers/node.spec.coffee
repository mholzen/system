node = require 'lib/mappers/node'

describe 'node', ->
  it 'object', ->
    data =
      a: 1
      b: {b1: 1}
      c: 3
      d: ->

    expect node data
    .eql
      value: {a:1, c:3}
      edges: ['b', 'd']

  it 'array with every index as node', ->
    expect node [1,2,3]
    .eql
      value: null
      edges: ['0','1','2']
