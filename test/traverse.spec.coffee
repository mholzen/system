searchers = require '../lib/generators/traverse'
{post, inodes: {inode}} = require '../lib'

describe.skip 'adjascent', ->

  it 'from root', ->
    adj = inode('/').adjascent()
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
