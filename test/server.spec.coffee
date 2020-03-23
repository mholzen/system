server = require '../server/'
request = require 'supertest'

s = new server.Server()
r = request s.app

describe.only 'server', ->
  it 'start', ->
    r.get '/'
    .expect 200
    .then (response)->
      expect response.text
      .includes 'generators'

  it 'literals/123', ->
    r.get '/literals/123'
    .expect 200
    .then (response)->
      expect response.text
      .eql '123'

  it 'mappers', ->
    r.get '/mappers'
    .expect 200
    .then (response)->
      expect response.text
      .length.above 0

  it 'mappers/html/literals/123', ->
    r.get '/mappers/html/literals/123'
    .expect 200
    .then (response)->
      expect response.text
      .includes '<p>123</p>'
  
  it 'files', ->
    r.get '/files'
    .expect 200
    .then (response)->
      expect response.text
      .length.above 0

  it 'mappers/html', ->
    r.get '/mappers/html'
    .expect 200 # processed the root document

  it '/type/css/literals/1', ->
    r.get '/type/css/literals/1'
    .expect 200
    .expect('Content-Type', /text\/css/)

  it 'searchers', ->
    r.get '/searchers'
    .expect 200
    # .expect('Content-Type', /text\/css/)

  it '/literals/1/map/html', ->
    r.get '/literals/1/map/html'
    # .expect 200
    .then (response)->
      expect response.text
      .includes '<p>1</p>'

  it '/files/test/artifacts/blurb.md/map/html', ->
      r.get '/files/test/artifacts/blurb.md/map/html'
      # .expect 200
      .then (response)->
        expect response.text
        .includes '<h1'

  it '/mappers/html/files/test/artifacts/image.jpg', ->
      r.get '/mappers/html/files/test/artifacts/image.jpg'
      # .expect 200
      .then (response)->
        expect response.text
        .includes '<img'
