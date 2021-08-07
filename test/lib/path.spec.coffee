{Path} = require  'lib/path'

describe 'path', ->
  it 'find path', ->
    path = new Path ['a'], {a:1}
    expect path.to
    .eql 1
    expect path.remainder()
    .eql []
    expect path.position
    .eql 0

    path = new Path ['a', 'b', 'c'], {a:{b:{c:1}}}
    expect path.to
    .eql 1
    expect path.remainder()
    .eql []
    expect path.position
    .eql 2

  it 'non object data', ->
    path = new Path ['a'], 'data'
    expect path.to
    .eql undefined

  it 'not find full path', ->
    path = new Path ['a', 'b', 'c'], {a:{b:1}}
    expect path.reached()
    .eql false
    expect path.position
    .eql 1
    expect path.remainder()
    .eql ['c']
    expect path.to
    .eql 1
