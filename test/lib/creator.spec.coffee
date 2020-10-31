{creator} = require  'lib'

describe 'creator', ->
  it 'works', ->
    expect creator
    .a 'function'

    factory = creator {a: (d)-> d}

    expect factory.a 1
    .eql 1

    f = factory 'a'
    expect f 1
    .eql 1

  it 'fails with a map that has specific names', ->
    factory = creator
      a: (d)->d
      name: (d)->d

    expect factory.name
    .not.a 'function'

    f = factory 'name'
    expect f 1
    .eql 1
