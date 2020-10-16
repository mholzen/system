{concat} = require 'lib/reducers'

describe 'concat', ->
  it 'works', ->
    [memo, reducer] = concat()

    expect [['a'],['b'],['c']].reduce reducer, memo
    .eql ['a','b','c']