tempy = require 'tempy'
inodes = require 'lib/inodes'
post = require 'lib/post'
_ = require 'lodash'
query = require 'lib/query'
stream = require 'lib/stream'

describe 'statAsync', ->
  it 'should know / as directory', ->
    inodes.statAsync('/').then (s)->
      expect(s.isDirectory()).true

describe 'inodes', ->

  it 'stat cwd', ->
    s = inodes()
    expect(s).property('path').eql process.cwd()

  it 'stat cwd', ->
    s = await inodes()
    expect(s).property('path').eql process.cwd()

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

  describe.skip 'get', ->
    it 'should return self with no arguments', ->
      cwd = inodes()
      expect(cwd).property('path').eql process.cwd()

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

    # TODO: convert to Path
    it.skip 'should get a resource path in a directory from root', ->
      dir = tempy.directory()
      file = await post 'abc', dir
      files =
      inodes('/').get(file+'/resource').then (f)->
        expect(f.path).equal file

    it.skip 'should get a resource path in a directory from root with remainder', ->
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
      results = await matches.collect().toPromise Promise
      expect(results).property(0).property 'path', file

    it 'fails', ->
      try
        s = await inodes().get('/some-path')
      catch err
        expect(err.stack).include 'get with absolute path does not match'

    it 'fails ENOENT', ->
      # i = inodes('/')
      # expect(await i.isDirectory()).true

      i = inodes('/tmp/foobar')
      i.isDirectory()
      .then ->
        fail()
      .catch (err)->
        expect(err).instanceof Error

    it.skip 'with await', ->
      path = [ 'tmp', 'foobar' ]
      try
        # i = await inodes('/').stat
        # i = i.get 'tmp/foobar'
        i = inodes('/')
        i = await i.get path
        fail()
      catch err
        expect(err).instanceof Error

  describe 'Path', ->
    it 'absolute', ->
      path = new inodes.Path '/tmp/foobar'
      expect(path.root).eql '/'
      expect(path.path).eql 'tmp/foobar'

    it 'relative with root', ->
      path = new inodes.Path 'foobar', '/tmp'
      expect(path.root).eql '/tmp'
      expect(path.path).eql 'foobar'

    it 'relative root', ->
      path = new inodes.Path 'foobar', 'tmp'
      expect(path.root.startsWith '/').true
      expect(path.path).eql 'foobar'

    it 'empty array with root', ->
      path = new inodes.Path [], '/tmp'
      expect(path.root).eql '/tmp'
      await path
      expect(path.stat).not.null

    it 'no root', ->
      path = new inodes.Path 'foo'
      expect(path.root).eql process.cwd()

    it 'root overspecified', ->
      f = -> new inodes.Path '/foo', '/tmp'
      expect(f).throws().property('message').contain 'overspecified'

    it 'file', ->
      # downside is that it will split all paths and tests them in sequence
      # rather than do a single stat to the full path name
      path = new inodes.Path '/bin/ls'
      expect(path.root).eql '/'
      expect(path.segments).eql [ 'bin', 'ls' ]
      await path
      expect(path.remainder).eql []
      expect(path.stat.isFile())
      expect(path.path).eql '/bin/ls'

    it 'non-existing file in directory', ->
      # downside is that it will split all paths and tests them in sequence
      # rather than do a single stat to the full path name
      path = new inodes.Path '/tmp/foobar'
      expect(path.root).eql '/'
      expect(path.segments).eql [ 'tmp', 'foobar' ]
      await path
      expect(path.remainder).eql ['foobar']
      expect(path.path).eql '/tmp'
      expect(path.stat.isDirectory())

    it 'non-existing file after file', ->
      # downside is that it will split all paths and tests them in sequence
      # rather than do a single stat to the full path name
      path = new inodes.Path '/bin/ls/foobar'
      expect(path.segments).eql [ 'bin', 'ls', 'foobar' ]
      expect(path.root).eql '/'
      await path
      expect(path.segments).eql [ 'bin', 'ls', 'foobar' ]
      expect(path.segments).eql [ 'bin', 'ls', 'foobar' ]
      expect(path.path).eql '/bin/ls'
      expect(path.stat.isFile())
