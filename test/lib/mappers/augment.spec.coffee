mappers = require 'lib/mappers'
augment = mappers.augment

describe 'augment', ->
  it 'works', ->
    expect augment {a:1}, Object.keys
    .eql {a:1, Array: ['a']}

    expect augment {a:1}, Object.keys, name:'keys'
    .eql {a:1, keys: ['a']}

    expect augment {a:1}, 2, name:'b'
    .eql {a:1, b: 2}

    expect augment {a:1}, 'marc', name:'name'
    .eql {a:1, name: 'marc'}


  it 'using options.resolve', ->
    resolve = (name)-> mappers[name]
    mapper = mappers 'augment', 'keys', {resolve, name:'keys'}
    expect mapper {a:1}
    .eql {a: 1, keys:['a']}