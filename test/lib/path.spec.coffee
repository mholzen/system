{Path} = require  'lib/path'

describe 'path', ->
  it 'find path', ->
    path = new Path ['a']
    expect path.follow {a:1}
    .eql true
    expect path.to
    .eql 1
    expect path.remainder()
    .eql []
    expect path.position
    .eql 0

    path = new Path ['a', 'b', 'c']
    expect path.follow {a:{b:{c:1}}}
    .eql true
    expect path.to
    .eql 1
    expect path.remainder()
    .eql []
    expect path.position
    .eql 2

  it 'non object data', ->
    path = new Path ['a']
    expect path.follow 'data'
    .eql false

  it 'not find full path', ->
    path = new Path ['a', 'b', 'c']
    expect path.follow {a:{b:1}}
    .eql false
    expect path.position
    .eql 1
    expect path.remainder()
    .eql ['c']
    expect path.to
    .eql 1
