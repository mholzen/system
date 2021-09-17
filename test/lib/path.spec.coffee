path = require  'lib/path'

describe 'path', ->
  it 'find path', ->
    p = path ['a'], {a:1}
    expect p.to
    .eql 1
    expect p.remainder()
    .eql []
    expect p.position
    .eql 0

    p = path ['a', 'b', 'c'], {a:{b:{c:1}}}
    expect p.to
    .eql 1
    expect p.remainder()
    .eql []
    expect p.position
    .eql 2

  it 'does not find path', ->
    p = path ['b'], {a:1}
    expect p.reached()
    .eql false
    expect p.to
    .eql {a: 1}
    expect p.remainder()
    .eql ['b']
    expect p.position
    .eql undefined


  it 'non object data', ->
    p = path ['a'], 'data'
    expect p.reached()
    .eql false
    expect p.to
    .eql 'data'

  it 'not find full path', ->
    p = path ['a', 'b', 'c'], {a:{b:1}}
    expect p.reached()
    .eql false
    expect p.position
    .eql 1
    expect p.remainder()
    .eql ['c']
    expect p.to
    .eql 1

  it 'handles root with array', ->
    p = path [,'a','b'], {a:{b:1}}
    expect p.reached()
    .eql true

  it 'handles root with string', ->
    p = path '.a.b', {a:{b:1}}
    expect p.reached()
    .eql true
