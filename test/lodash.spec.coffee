_ = require 'lodash'

describe 'lodash', ()->
  it 'set', ->
    expect _.set {}, ['a', 'b'], 1
    .eql {a:{b:1}}

    expect _.set {}, ['a', 'b.c'], 1
    .eql {a:{'b.c':1}}
