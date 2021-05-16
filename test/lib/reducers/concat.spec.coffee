{concat} = require 'lib/reducers'

describe 'concat', ->
  it 'works with arrays', ->
    reducer = concat.create()

    expect [['a'],['b'],['c']].reduce reducer, null
    .eql ['a','b','c']

  it 'works with strings', ->
    reducer = concat.create()

    expect ['a','b','c'].reduce reducer, null
    .eql 'abc'