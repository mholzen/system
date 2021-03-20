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

  it.skip 'with side effects', ->
    c = 0
    f = -> ++c

    factory = creator
      a: f
      no_side_effect:
        create: f

    expect (factory 'a') 1
    .eql 1
    expect (factory 'a') 1
    .eql 1


  it 'no side effects', ->

    factory = creator
      a:
        create: ->
          c = 0
          -> ++c

    expect (factory 'a') 1
    .eql 1
    expect (factory 'a') 1
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

  it 'finds given array', ->
    factory = creator
      a:
        b: -> 1

    f = factory ['a','b']
    expect f()
    .eql 1