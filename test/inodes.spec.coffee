inodes = require '../lib/inodes'
tempy = require 'tempy'

describe 'statAsync', ->
  it 'should know / as directory', ->
    inodes.statAsync('/').then (s)->
      expect(s.isDirectory()).true

describe 'inodes', ->
  it 'should return path of cwd', ->
    inodes().isDirectory().then (r)->
      expect(r).true

  it 'should return items of cwd', (done)->
    inodes().items.head().toArray (r)->
      expect(r[0]).property('path').startsWith '/'
      done()

  it 'should return items of empty directory', (done)->
    directory = tempy.directory()
    inodes(directory).items.toArray (r)->
      expect(r.length).equal 0
      done()
