require '../../server.spec'
mappers = require 'lib/mappers'
generators = require 'lib/generators'
stream = require 'lib/stream'
inodes = require 'lib/inodes' # TODO: make it a async mapper

server = require 'server'
request = require 'supertest'

r = null

describe 'integration', ->
  beforeEach ->
    s = new server.Server()
    r = request s.app

  describe.only 'navigate directories', ->
    it 'works', ->
      # r.get '/files,statDirectories:true/test/artifacts/map/link/apply/html'
#      r.get '/files/test/artifacts/map/augment,stat/apply/resolve/map/link/apply/html'
#      r.get '/files/test/map/array/map/prepend,req.dirname/map/join/map/augment,stat/apply/resolve'
      r.get '/files/test/artifacts/map/object,name:name/map/augment,req.dirname,name:directory/map/augment,req.base,name:base/map/augment,stat,name:stat/apply/resolve/map/link/apply/html'
      .then (res)->
        expect res.text
        .includes '<li><a href='
        .includes 'image.html'

    it 'inode generator', ->
      f = generators 'stat'
      r = await stream [ 'test/artifacts' ]
      .flatMap f
      .collect().toPromise Promise

      expect r
      .property(0).respondsTo 'isFile'

    it 'inode directory generator', ->
      f = generators 'files'
      expect f
      .a 'function'

      r = await stream [ 'test/artifacts' ]
      .flatMap f
      .collect().toPromise Promise

      expect r
      .property(0).respondsTo 'isFile'

    it 'link resources based on stat', ->
      dir = await inode '/tmp'
      expect mappers 'link', dir
      .property 'href'
      .include 'map/link/apply/html'
