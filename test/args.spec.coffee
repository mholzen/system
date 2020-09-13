args = require '../lib/mappers/args'

describe 'args', ->
  it 'basic', ->
    expect args [1,2,3]
    .eql {0:1, 1:2, 2:3}

    expect args ['a', 'b', 'c']
    .eql {0:'a', 1:'b', 2:'c'}

    expect args ['a:1', 'b:b', 'c', ':']
    .eql {a:1, b:'b', 2:'c', 3:':'}

    expect args [{a:1}]
    .eql {'0':{a:1}}

    expect args '1,2,a:1'
    .eql {0:1, 1:2, a:1}

    expect args.positional args ['a:1', 'b:b']
    .eql null

    expect args.positional args ['a:1', 'b:b', 'c', 'd:1', 'b']
    .eql ['c', 'b']

    expect args.positional args ['a:1', 'b:b', 'c']
    .eql ['c']

    expect args.positional args ['a', 'b', 'c:x', 'd:y']
    .eql ['a', 'b']


  it 'two levels', ->
    expect args ['a:b:1']
    .eql a: b: 1

  describe 'interpet filenames', ->
    it.skip 'two levels with .', ->
      expect args ['a.b:1']   # 'a:b:1' works too
      .eql a: b: 1