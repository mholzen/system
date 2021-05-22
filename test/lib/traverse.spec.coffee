traverse = require  'lib/traverse'
mappers = require  'lib/mappers'
inodes = require  'lib/inodes'
{objectValue, objectEdges} = traverse
{stream, post, inodes: {inode}} = require  'lib'

describe 'objectValue', ->
  it 'array', ->
    expect objectValue [1,2,3]
    .eql null

describe 'edges, value, traverse', ->
  it 'null', ->
    expect Array.from traverse null
    .eql []

  it 'undefined', ->
    expect Array.from traverse()
    .eql []

  it 'array', ->
    a = ['a','b','c']
    r = Array.from traverse a
    expect(a).eql a

  it 'object', ->
    object =
      a: 1
      b: {b1: 1}
      c: 3
    expect(objectEdges(object)).eql ['b']
    expect(objectValue(object)).eql {a:1, c:3}
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

  it 'array', ->
    array = [1,[21, 22],3]
    expect(objectEdges(array)).eql ['0', '1', '2']

    it = traverse array, path:true
    result = Array.from it
    expect(result).eql [
      {value: 1, path: ['0']}
      {value: 21, path: ['1', '0']}
      {value: 22, path: ['1', '1']}
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

describe.skip 'traverse inodes', ->

  describe 'inodes', ->
    it 'from root', ->

      root = await inode '/'

      adj.toArray (inodes)->
        expect(inodes).length 0

    it 'from a file', ->
      file = await post 'data'
      inodes = inode(file).adjascent()
      inodes.toArray (inodes)->
        expect(inodes).length 2

    it 'filename in file', ->
      file = await post '/tmp/', '/tmp/foo'

    it 'references from content', ->
      refs = references '/'
      refs = references '.'
      refs = references './file'
      refs = references 'http://google.com'
