# {traverse} = require '../lib/generators'

object =
  a: 1
  b: {b1: 1}
  c: 3

describe 'iterator1', ->
  it 'array', ->
    array = [1,[21, 22],3]
    i = array[Symbol.iterator]()
    expect(Array.from(i)).eql [1, [21,22], 3]

  it 'flatten', ->
    array = [1,[21, 22],3]
    traverse = (data)->data.flat()[Symbol.iterator]()
    it = traverse array
    result = Array.from it
    expect(result).eql [1, 21, 22, 3]

  it 'using yield', ->
    traverse = (data)->
      i = 0
      while i < data.length
        if not (data[i] instanceof Array)
          yield data[i]
        else
          for v from traverse data[i]
            yield v
        i++

    it = traverse [1,[21, 22],3]

    result = Array.from it
    expect(result).eql [1, 21, 22, 3]

  it 'object', ->
    object =
      a: 1
      b: {b1: 1}
      c: 3

    edges = (data) -> Object.keys(data).filter (k) -> typeof data[k] == 'object'
    expect(edges(object)).eql ['b']

    value = (data) ->
      e = edges data
      _.pickBy data, (v,k) -> not e.includes k
    expect(value(object)).eql {a:1, c:3}
    expect(value(object.b)).eql {b1: 1}

    traverse = (data)->
      v = value(data)
      if not _.isEmpty v
        yield v

      for e from edges(data)
        for i from traverse data[e]
          yield i

    it = traverse object

    result = Array.from it
    expect(result).eql [{a:1, c:3}, {b1:1}]


edges = (data) ->
  if data instanceof Array
    return Object.keys data
  if data == null
    return []
  Object.keys(data).filter (k) -> typeof data[k] == 'object'

value = (data) ->
  if ['string', 'number'].includes typeof data
    return data
  if typeof data == 'object'
    e = edges data
    v  =_.pickBy data, (v,k) -> not e.includes k
    return if _.isEmpty v then null else v
  throw new Error "value not implemented for #{typeof data}"

traverse = (data, options)->
  options ?= {}
  v = value(data)
  if v != null
    if options.path
      v = {value: v, path: []}
    yield v

  for e from edges(data)
    for i from traverse data[e], options
      if options.path
        i.path.unshift e
      yield i

describe 'iterator2', ->
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

describe 'iterator.paths', ->
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

  it 'mappers', ->
    graph = m for m from traverse system.searchers, path:true when m.path.includes 'graph'
    expect(graph).property('value').property('template').includes 'graph.links'
