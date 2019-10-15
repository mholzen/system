inodes = require '../lib/inodes'
tempy = require 'tempy'
post = require '../lib/post'
_ = require 'lodash'
query = require '../lib/query'
stream = require '../lib/stream'

describe 'statAsync', ->
  it 'should know / as directory', ->
    inodes.statAsync('/').then (s)->
      expect(s.isDirectory()).true

describe 'inodes', ->
  it 'should return path of cwd', ->
    inodes().isDirectory().then (r)->
      expect(r).true

  it 'should return entries() of cwd', (done)->
    inodes().entries().head().toArray (r)->
      expect(r[0]).property('path').startsWith '/'
      done()

  it 'should return entries() of empty directory', (done)->
    directory = tempy.directory()
    inodes(directory).entries().toArray (r)->
      expect(r.length).equal 0
      done()

  it 'should find a file in a new directory', ->
    directory = tempy.directory()
    resource = await post 'foo', directory
    new Promise (resolve)->
      i = inodes(directory).entries().toArray (r)->
        expect(r.length).equal 1
        resolve true

  describe 'get', ->
    it 'should return self with no arguments', ->
      cwd = inodes()
      cwd.get().then (i)->
        expect(i).equal cwd

    it 'should return self with empty array', ->
      cwd = inodes()
      cwd.get([]).then (i)->
        expect(i).equal cwd

    it 'should return self with .', ->
      cwd = inodes()
      cwd.get('.').then (i)->
        expect(i.path).equal cwd.path

    it 'should return a file in a directory', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      inodes(dir).get(file).then (f)->
        expect(file).equal f.path

    it 'should return a file in a directory from root', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      inodes('/').get(file).then (f)->
        expect(file).equal f.path

    it 'should get a resource path in a directory from root', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      files =
      inodes('/').get(file+'/resource').then (f)->
        expect(f.path).equal file

    it 'should get a resource path in a directory from root with remainder', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      file = file.split '/'
      file.push 'resource'
      inodes('/').get(file).then (f)->
        expect(file).eql ['resource']

    it 'should stream files in a directory', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      entries = await inodes(dir).entries().collect().toPromise(Promise)
      expect(entries).property(0).property 'path', file

    it 'match', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      matches = query(file).match inodes(dir).entries()
      results = await matches[0].value.collect().toPromise Promise
      expect(results).property(0).property 'path', file
