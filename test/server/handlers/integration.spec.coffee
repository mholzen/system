require '../../server.spec'
mappers = require 'lib/mappers'
generators = require 'streams/generators'
stream = require 'lib/stream'
inodes = require 'lib/inodes' # TODO: make it a async mapper

server = require 'server'
request = require 'supertest'

s = null
r = null

get = (a...)->
  if a[0] instanceof Array
    a[0] = a[0].join '/'

  log.debug "GET #{a[0]}"
  request s.app
  .get a...

describe 'integration', ->
  before ->
    # log.debug 'new server'
    s = new server.Server()

  beforeEach ->
    r = request s.app

  describe 'navigate directories', ->
    it 'works', ->
      get [
        '/files/test/artifacts'
        'map,mappers.object,name:name'
        'map,mappers.augment,req.dirname,name:directory'  # TODO: 'cannot find req.dirname' should throw
        'map,mappers.augment,req.base,name:base'
        'map,mappers.augment,mappers.stat,name:stat'
        'apply,mappers.resolve'
        'map,mappers.link'
        'apply,mappers.html'
      ]
      .then (res)->
        expect res.text
        .match /<li>[^<]*<a href=/
        .includes 'image.html'

    it 'should have different postfix url/remainder maps depending on file type', ->
      get [ '/files/test/artifacts'
        'map,mappers.object,name:name'
        'map,mappers.augment,req.dirname,name:directory'
        'map,mappers.augment,req.base,name:base'
        'map,mappers.augment,mappers.stat,name:stat'
        'apply,mappers.resolve'
        'map,mappers.link'
        'apply,mappers.html'
      ]
      .then (res)->
        expect res.text
        .match /<li>[^<]*<a href=[^<]*<img/
        .includes 'image.html'

  describe.skip '?', ->
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
      .include 'map/link/apply,mappers.html'

  describe.skip 'traverse directories up to N deep, display as graph'

  describe 'spending by accounts', ->
    it.skip 'works', ->
      r.get '/files/test/artifacts/marchome/data/accounts/mint.com/transactions.csv'
      + '/reduce/table'
      + '/rowsByColumns,account:capitalOne'
      + '/valueByTime,time:daily'

  describe 'graph with edges', ->
    it 'works', ->
      get [ '/files/test/artifacts/graph.json'
        'apply,mappers.parse'
        'apply,mappers.graph'
        'apply,mappers.dict,name:graph'
        'apply,reducers.inject,.files.lib.mappers.templates.graph.html'
      ]
      .then (res)->
        expect res.text
        .match /links: \[{"source":0,"target":1}/

  describe 'turtle to graph', ->
    it 'works', ->
      r.get '/files/test/artifacts/graph.ttl/generator/triples/reduce/graph'

  describe 's2s traceroute', ->
    it 'works', ->
      [
        'files/test/artifacts/s2s.csv'
        'apply,mappers.table'
        'apply,mappers.column,report'
        'map/dict'
        'map/get,traceroute'
        'map/hops'
        'map/get,legs'
        'apply,mappers.get,0' # DEBUG, TEST
        # 'reduce/concat' # PROD
        'reduce/graph'
        'map/pick,source,target,pings,delta'
      ]

      # http://localhost:3001/files/test/artifacts/s2s.csv/apply,mappers.table/apply,mappers.column,report/map/dict/map/get,traceroute/map/hops/map/get,legs/reduce/concat/map/pick,source,target,delta/Graph

  describe 'graph from symlinks', ->
    it 'works', ->
      get [
        '/files/test/artifacts'
        'map,mappers.object,name:name'
        'map,mappers.augment,req.dirname,name:directory'
        'map,mappers.augment,mappers.fs.readlink,name:symlink'
        'apply,mappers.resolve'
        'transform,transformers.filter,string,path:symlink'
      ].join '/'
      .then (res)->
        expect res.text
        .include 'non-existent'
        .include 'blurb.txt'
        .include 'marchome'

  describe 'reduce to a map using any other command', ->
    it 'works', ->
      get [
        '/files/test/artifacts/names.csv'
        'reduce/map,key:0'
        'map,mappers.keys'
      ].join '/'
      .then (res)->
        expect res.text
        .include 'Marc'
        .not.include 'von Holzen'