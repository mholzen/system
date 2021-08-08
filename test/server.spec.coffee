server = require 'server'
request = require 'supertest'
requireDir = require 'require-dir'

require 'test/lib.spec'
require 'test/server/router.spec'
require 'test/streams/streams.spec'
requireDir './server/handlers'

{parse} = require 'lib/mappers'
r = null

beforeEach ->
  s = server()
  r = request s.app

describe 'server', ->
  it '/mappers/process', ->
    r.get '/mappers/process'
    .then (response)->
      expect response.text
      .includes 'uptime'

  it '/apply,mappers.process.uptime', ->
    r.get '/apply,mappers.process.uptime'
    .then (response)->
      expect parseInt response.text
      .above 0

  it '/mappers/process/', ->
    r.get '/mappers/process/'
    .then (response)->
      expect parse response.text
      .property 'length'
      .above 0

  it 'start', ->
    r.get '/'
    .expect('Content-Type', /application\/json/)
    .then (response)->
      expect response.text
      .includes 'generators'
      expect response.status
      .eql 200
      
  it 'literals/123', ->
    r.get '/literals/123'
    .then (response)->
      expect response.text
      .eql '123'

  it 'mappers', ->
    r.get '/mappers'
    .then (response)->
      expect response.text
      .startsWith '{'

  it '/literals/123/apply,mappers.html', ->
    r.get '/literals/123/apply,mappers.html'
    .then (response)->
      expect response.text
      .includes '<p>123</p>'
  
  it 'files', ->
    r.get '/files'
    .then (response)->
      expect response.text
      .contain 'test'
      .contain 'bin'
      .contain 'package.json'

  it '/literals/1/type/css', ->
    r.get '/literals/1/type/css'
    .expect('Content-Type', /text\/css/)

  it.skip 'searchers', ->
    r.get '/searchers'
    # .expect('Content-Type', /text\/css/)

  it '/files/test/artifacts/blurb.md/apply,mappers.html', ->
    r.get '/files/test/artifacts/blurb.md/apply,mappers.html'
    .then (response)->
      expect response.text
      .includes '<table'

  # TODO: what should be expected?
  it.skip '/files/test/artifacts/image.jpg/apply,mappers.html', ->
    r.get '/files/test/artifacts/image.jpg/apply,mappers.html'
    .then (response)->
      expect response.text
      .includes '<img'

  it '/searchers/inodes', ->
    r.get '/searchers/inodes'
    .then (response)->
      expect response.text
      .includes '"path":'

  it '/files/test/artifacts/names.csv/generate,generators.lines/map,mappers.split', ->
    r.get '/files/test/artifacts/names.csv/generate,generators.lines/map,mappers.split'
    .then (response)->
      expect response.text
      .includes '[["First","Last"],['

  it.skip 'difference between dir and dir/', ->
    r.get '/files/test/artifacts'
    .then (response)->
      expect response.text
      .includes '["file1", "file2"]'

    r.get '/files/test/artifacts/'
    .then (response)->
      expect response.text
      .includes '[{"name:"file1",'

  describe 'images to html', ->
    it 'one image', ->
      # should mappers.html handle requests?
      # if so, mappers.html should realize the data is an image, and but the response type to html
      # how would a mapper function affect the outgoing headers?
      r.get '/files/test/artifacts/image.png/type/png/apply,mappers.html'
      .then (response)->
        expect response.text
        .includes '<img'

    it 'list of resources', ->
      r.get '/files/test/artifacts/transform,transformers.head/map,mappers.image/apply,mappers.html/apply,mappers.style,thumbnails'  # TODO: make style a mapper
      .then (res)->
        expect res.text
        .includes '<img'
        .includes '<link'
        .includes 'thumbnails'

  describe 'count words in logs', ->
    it '.../pick,a,b,c', ->
      r.get '/files/test/artifacts/array.json/apply,mappers.parse/map,mappers.pick,a,c'
      .then (res)->
        expect res.text
        .includes '1'
        .includes '3'
        .includes '4'
        .includes '7'

    it 'works', ->
      r.get [
        '/apply,mappers.os.homedir'
        'files/data/logs/index.json'
        'generate,generators.lines'
        'map,mappers.parse'
        'map,mappers.get,log'
        'map,mappers.words'
        'reduce,reducers.concat'
        'reduce,reducers.distribution'
        'apply,mappers.entries'
        'apply,mappers.sort'
      ].join '/'
      .then (res)->
        expect res.text
        .includes 'sad'

describe.skip 'post/put a redirect (301/302)', ->
  it '', ->
    r.post '/artifacts', '/files/test/artifacts'
    r.get '/artifacts'

describe.skip 'directory to index-page'

describe.skip 'post', ->
  it 'path with function (apply) takes one path argument (a template function)', ->
    r.post '/mappers/pug/example', 'p a:#{a} b:#{b}'
    .then (response)->
      r.get '/files/test/artifacts/dict.json/apply,mappers.pug/example'
      .then (response)->
        expect response.text
        .includes '<p>a:1 b:2</p>'
