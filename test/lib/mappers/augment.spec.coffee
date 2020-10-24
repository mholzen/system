mappers = require 'lib/mappers'
augment = mappers.augment

describe.skip 'identify', ->    # TODO: move to its own file
  it 'works', ->
    expect identify 1
    .eql 'Number'

    expect identify {a:1}
    .eql 'Object'


describe 'augment', ->
  it.only 'works', ->
    expect augment {a:1}, Object.keys
    .eql {a:1, Array: ['a']}

    expect augment {a:1}, Object.keys, name:'keys'
    .eql {a:1, keys: ['a']}

    expect augment {a:1}, 2, name:'b'
    .eql {a:1, b: 2}

    expect augment {a:1}, 'marc', name:'name'
    .eql {a:1, name: 'marc'}


  it 'from mappers', ->
    # TODO: consider: when obtaining a mapper using a factory, we can pass it a dictionary of functions
    mappers =
      keys: Object.keys
    resolve = (name)-> mappers[name]
    augment2 = mappers 'augment', {keys}, resolve:mappers
    expect augment2 {a:1}, 'keys'
    # expect augment {a:1}, 'keys'
    # .eql {a: 1, keys:['a'] }
    # expect augment {a:1}, 'keys'
    # .eql {a: 1, keys:['a'] }