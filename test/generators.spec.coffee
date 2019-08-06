{edges, value, traverse} = require '../lib/generators'

describe 'generators', ->
  it 'edges, value, traverse', ->
    object =
      a: 1
      b: {b1: 1}
      c: 3

    array = [1,[21, 22],3]

    expect(edges(object)).eql ['b']
    expect(edges(array)).eql ['0', '1', '2']

    expect(value(object)).eql {a:1, c:3}
    expect(value(object.b)).eql {b1: 1}
    expect(value(array[0])).eql 1

    it = traverse object
    result = Array.from it
    expect(result).eql [{a:1, c:3}, {b1:1}]

    it = traverse array
    result = Array.from it
    expect(result).eql [1, 21, 22, 3]

    object2 =
      val: 1
      children: [
        {val: 2}
        {val: 3}
      ]
    it = traverse object2
    result = Array.from it
    expect(result).eql [{val: 1}, {val: 2}, {val:3}]

describe 'generators', ->
  it 'object and array', ->
    object =
      a: 1
      b: {b1: 1}
      c: 3

    array = [1,[21, 22],3]

    expect(edges(object)).eql ['b']
    expect(edges(array)).eql ['0', '1', '2']

    expect(value(object)).eql {a:1, c:3}
    expect(value(object.b)).eql {b1: 1}
    expect(value(array[0])).eql 1

    it = traverse object, path:true
    result = Array.from it
    expect(result).eql [
      {value: {a:1, c:3}, path: []}
      {value: {b1:1}, path: ['b']}
    ]

    it = traverse array, path:true
    result = Array.from it
    expect(result).eql [
      {value: 1, path: ['0']}
      {value: 21, path: ['1', '0']}
      {value: 22, path: ['1', '1']}
      {value: 3, path: ['2']}
    ]

    object2 =
      val: 1
      children: [
        {val: 2}
        {val: 3}
      ]
    it = traverse object2, path:true
    result = Array.from it
    expect(result).eql [
      {value: {val:1}, path: []}
      {value: {val:2}, path: ['children', '0']}
      {value: {val:3}, path: ['children', '1']}
    ]

  it 'traverse searchers', ->
    graph = m for m from traverse system.searchers, path:true when m.path.includes 'graph'
    expect(graph).property('value').property('template').includes 'graph.links'
