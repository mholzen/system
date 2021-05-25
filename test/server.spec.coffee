server = require 'server'
request = require 'supertest'
requireDir = require 'require-dir'

require 'test/lib.spec'
require 'test/server/router.spec'
require 'test/streams/generators.spec'
requireDir './server/handlers'

{parse} = require 'lib/mappers'
r = null

describe 'server', ->
  beforeEach ->
    s = server()
    r = request s.app

  it '/measures', ->
    r.get '/measures'
    .then (response)->
      expect response.text
      .includes 'uptime'

    r.get '/measures/uptime'
    .then (response)->
      expect parseInt response.text
      .above 0

    r.get '/measures/'
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

  it '/literals/123/apply/html', ->
    r.get '/literals/123/apply/html'
    .then (response)->
      expect response.text
      .includes '<p>123</p>'
  
  it 'files', ->
    r.get '/files'
    .then (response)->
      expect response.text
      .contain 'root'
      .contain 'home'
      .contain 'cwd'

  it '/literals/1/type/css', ->
    r.get '/literals/1/type/css'
    .expect('Content-Type', /text\/css/)

  it.skip 'searchers', ->
    r.get '/searchers'
    # .expect('Content-Type', /text\/css/)

  it '/files/cwd/test/artifacts/blurb.md/apply/html', ->
    r.get '/files/cwd/test/artifacts/blurb.md/apply/html'
    .then (response)->
      expect response.text
      .includes '<table'

  # TODO: what should be expected?
  it.skip '/files/cwd/test/artifacts/image.jpg/apply/html', ->
    r.get '/files/cwd/test/artifacts/image.jpg/apply/html'
    .then (response)->
      expect response.text
      .includes '<img'

  it '/searchers/inodes', ->
    r.get '/searchers/inodes'
    .then (response)->
      expect response.text
      .includes '"path":'

  it '/files/cwd/test/artifacts/names.csv/generators/lines/map/split', ->
    r.get '/files/cwd/test/artifacts/names.csv/generators/lines/map/split'
    .then (response)->
      expect response.text
      .includes '[["First","Last"],['

  it.skip 'difference between dir and dir/', ->
    r.get '/files/cwd/test/artifacts'
    .then (response)->
      expect response.text
      .includes '["file1", "file2"]'

    r.get '/files/cwd/test/artifacts/'
    .then (response)->
      expect response.text
      .includes '[{"name:"file1",'

  describe 'images to html', ->
    it 'one image', ->
      # should mappers.html handle requests?
      # if so, mappers.html should realize the data is an image, and but the response type to html
      # how would a mapper function affect the outgoing headers?
      r.get '/files/cwd/test/artifacts/image.png/type/png/apply/html'
      .then (response)->
        expect response.text
        .includes '<img'

    it 'list of resources', ->
      r.get '/files/cwd/test/artifacts/marchome/images/transform/head/map/image/reduce/html/apply/style,thumbnails'  # TODO: make style a mapper
      .then (res)->
        expect res.text
        .includes '<img'
        .includes '<link'
        .includes 'thumbnails'

  describe 'count words in logs', ->
    it '.../pick,a,b,c', ->
      r.get '/files/cwd/test/artifacts/array.json/apply/parse/map/pick,a,c'
      .then (res)->
        expect res.text
        .includes '1'
        .includes '3'
        .includes '4'
        .includes '7'

    it 'works', ->
      r.get [
        '/files/cwd/test/artifacts/marchome/data/logs/index.json'
        'generators/lines'
        'map/parse'
        'map/get,log'
        'map/words'
        'reduce/concat'
        'reduce/distribution'
        'apply/entries'
        'apply/sort'
      ].join '/'
      .then (res)->
        expect res.text
        .includes 'sad'

describe.skip 'post/put a redirect (301/302)', ->
  it '', ->
    r.post '/artifacts', '/files/cwd/test/artifacts'
    r.get '/artifacts'

describe.skip 'directory to index-page'

describe.skip 'post', ->
  it 'path with function (apply) takes one path argument (a template function)', ->
    r.post '/mappers/pug/example', 'p a:#{a} b:#{b}'
    .then (response)->
      r.get '/files/cwd/test/artifacts/dict.json/apply/pug/example'
      .then (response)->
        expect response.text
        .includes '<p>a:1 b:2</p>'
