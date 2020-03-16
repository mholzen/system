server = require '../server/'
request = require 'supertest'

s = new server.Server()
r = request s.app

describe 'server', ->
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
  
  it 'mappers', ->
    r.get '/mappers'
    .expect 200
    .then (response)->
      expect response.text
      .length.above 0

  it 'mappers/html', ->
    r.get '/mappers/html'
    .expect 400

  it '/type/css/literals/1', ->
    r.get '/type/css/literals/1'
    .expect 200
    .expect('Content-Type', /text\/css/)
