server = require '../server/'
request = require 'supertest'

r = null

describe 'server', ->
  before ->
    s = new server.Server()
    r = request s.app

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
    .expect 200
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
      .contain 'index.coffee' 

  it 'mappers/apply/html', ->
    r.get '/mappers/apply/html'
    .expect 200 # processed the root document

  it '/literals/1/type/css', ->
    r.get '/literals/1/type/css'
    .expect 200
    .expect('Content-Type', /text\/css/)

  it.skip 'searchers', ->
    r.get '/searchers'
    .expect 200
    # .expect('Content-Type', /text\/css/)

  it '/files/reduce/count', ->
    r.get '/files/reduce/count'
    .then (response)->
      expect parseInt response.text
      .above 2

  it '/files/test/artifacts/blurb.md/apply/html', ->
    r.get '/files/test/artifacts/blurb.md/apply/html'
    .then (response)->
      expect response.text
      .includes '<table'

  # TODO: what should be expected?
  it.skip '/files/test/artifacts/image.jpg/apply/html', ->
    r.get '/files/test/artifacts/image.jpg/apply/html'
    .then (response)->
      expect response.text
      .includes '<img'

  it '/searchers/inodes', ->
    r.get '/searchers/inodes'
    # .expect 200
    .then (response)->
      expect response.text
      .includes '"path":'

  it '/files/test/artifacts/names.csv/generators/lines/map/split', ->
    r.get '/files/test/artifacts/names.csv/generators/lines/map/split'
    # .expect 200
    .then (response)->
      expect response.text
      .includes '[["First","Last"],['

  it '...reducer/table', ->
    r.get '/type/text/files/test/artifacts/names.csv/generators/lines/map/split/reducers/table'
    # .expect 200
    .then (response)->
      expect response.text
      .includes '{' # JSON of a table


  it.skip 'difference between dir and dir/', ->
    r.get '/files/test/artifacts'
    # .expect 200
    .then (response)->
      expect response.text
      .includes '["file1", "file2"]'

    r.get '/files/test/artifacts/'
    # .expect 200
    .then (response)->
      expect response.text
      .includes '[{"name:"file1",'


describe 'post', ->
  it.skip 'path with function (apply) takes one path argument (a template function)', ->
    r.post '/mappers/pug/example', 'p a:#{a} b:#{b}'
    .expect 200
    .then (response)->
      r.get '/files/test/artifacts/dict.json/apply/pug/example'
      .then (response)->
        expect response.text
        .includes '<p>a:1 b:2</p>'

