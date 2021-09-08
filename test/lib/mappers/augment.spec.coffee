mappers = require 'lib/mappers'
augment = mappers.augment

describe 'lib/mappers/augment/create', ->
  it 'accepts a function', ->
    f = augment.create Object.keys
    expect f {a:1}
    .eql {a:1, keys: ['a']}

describe 'lib/mappers/augment', ->
  it 'accepts a function', ->
    expect augment {a:1}, Object.keys
    .eql {a:1, keys: ['a']}

    expect augment {a:1}, Object.keys, name:'foo'
    .eql {a:1, foo: ['a']}

  it.skip 'accepts a number', ->
    expect augment {a:1}, 2, name:'b'
    .eql {a:1, b: 2}

  it.skip 'accepts a string', ->
    expect augment {a:1}, 'marc', name:'name'
    .eql {a:1, name: 'marc'}

  it 'using options.resolve', ->
    resolve = mappers
    mapper = mappers 'augment', 'keys', {resolve, name:'keys'}
    expect mapper {a:1}
    .eql {a: 1, keys:['a']}

  it 'using fs', (done)->
    root = mappers.all
    mapper = mappers 'augment', 'fs.readlink', {root, name: 'readlink'}    # TODO: a mouthful

    res = mapper '/'
    expect res
    .property 'readlink'
    .a 'Promise'

    res.readlink.catch (e)->
      done()

    null

  it 'from object', ->
    expect augment {}, 'a.b.c', {a:{b:{c:1}}}
    .eql
      'a.b.c': 1

