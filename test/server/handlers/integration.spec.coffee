require '../../server.spec'
mappers = require 'lib/mappers'
generators = require 'lib/generators'
stream = require 'lib/stream'
inodes = require 'lib/inodes' # TODO: make it a async mapper

server = require 'server'
request = require 'supertest'

s = null
r = null

get = (a...)->
  request s.app
  .get a...

describe 'integration', ->
  before ->
    s = new server.Server()
  beforeEach ->
    r = request s.app

  describe 'navigate directories', ->
    it 'works', ->
      # r.get '/files,statDirectories:true/test/artifacts/map/link/apply/html'
#      r.get '/files/test/artifacts/map/augment,stat/apply/resolve/map/link/apply/html'
#      r.get '/files/test/map/array/map/prepend,req.dirname/map/join/map/augment,stat/apply/resolve'
      get '/files/test/artifacts/map/object,name:name/map/augment,req.dirname,name:directory/map/augment,req.base,name:base/map/augment,stat,name:stat/apply/resolve/map/link/apply/html'
      .then (res)->
        expect res.text
        .match /<li>[^<]*<a href=/
        .includes 'image.html'

    it 'should have different postfix url/remainder maps depending on file type', ->
      r.get '/files/test/artifacts/map/object,name:name/map/augment,req.dirname,name:directory/map/augment,req.base,name:base/map/augment,stat,name:stat/apply/resolve/map/link/apply/html'
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
      .include 'map/link/apply/html'

describe.skip 'traverse directories up to N deep, display as graph'
describe.skip 'move /files to /generators/files'

describe 'spending by accounts', ->
  it.skip 'works', ->
    r.get '/files/test/artifacts/marchome/data/accounts/mint.com/transactions.csv'
    + '/reduce/table'
    + '/rowsByColumns,account:capitalOne'
    + '/valueByTime,time:daily'

describe 'graph with edges', ->
  it 'works', ->
    r.get '/files/test/artifacts/graph.json/generators/json/apply/graph/apply/dict,name:graph/apply/template,template:name:Graph/type/html'
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
      'apply/table',
      'apply/column,report',
      'map/dict',
      'map/get,traceroute',
      'map/hops',
      'map/get,legs',
      'apply/get,0', # DEBUG, TEST
      # 'reduce/concat' # PROD
      'reduce/graph',
      'map/pick,source,target,pings,delta'
    ]

    # http://localhost:3001/files/test/artifacts/s2s.csv/apply/table/apply/column,report/map/dict/map/get,traceroute/map/hops/map/get,legs/reduce/concat/map/pick,source,target,delta/Graph

describe 'symlink', ->
  it 'works', ->
    [
      'files/test/artifacts/symlink/lstat'
    ]

