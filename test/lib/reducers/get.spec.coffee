{get} = require  'lib/reducers'

describe 'get', ->
  it 'works', ->
    object = {a: {b: {c: 1}}}
    data = ['a', 'b', 'c']

    expect data.reduce get
    , object
    .eql 1