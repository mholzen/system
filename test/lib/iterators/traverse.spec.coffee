traverse = require  'lib/iterators/traverse'
{stream, post, inodes: {inode}} = require  'lib'

describe 'traverse', ->
  it 'null', ->
    expect Array.from traverse null
    .eql []

  it 'literal', ->
    expect Array.from traverse 1
    .eql [
      {value: 1, path: []}
    ]

  it 'array', ->
    a = ['a','b','c']
    r = Array.from traverse a, noPath:true
    expect(a).eql a

  it 'object', ->
    object =
      a: 1
      b: {b1: 1}
      c: 3

    it = traverse object, path:true
    result = Array.from it
    expect(result).eql [
      {value: {a:1, c:3}, path: []}
      {value: {b1:1}, path: ['b']}
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

  it 'array with array', ->
    array = [1,[21, 22],3]

    it = traverse array
    result = Array.from it

    expect(result).eql [
      {value: 1, path: ['0']}
      {value: 21, path: ['1','0']}
      {value: 22, path: ['1','1']}
      {value: 3, path: ['2']}
    ]

  it 'stream traverse', ->
    # a stream is considered a node, so traversing the stream simply returns that node
    s = stream [1,2,3]
    r = Array.from traverse s
    expect r
    .property '0'
    .property 'value'
    .eql s
