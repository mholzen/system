server = require '../../../server/'
request = require 'supertest'

r = null

describe 'servers/handlers/apply', ->
  before ->
    s = new server.Server()
    r = request s.app

  it '/literals/123/apply/html', ->
    r.get '/literals/123/apply/html'
    .then (response)->
      expect response.text
      .includes '<p>123</p>'
  
  it 'mappers/apply/html', ->
    r.get '/mappers/apply/html'
    .expect 200 # processed the root document

  it '/files/test/artifacts/blurb.md/apply/html', ->
    r.get '/files/test/artifacts/blurb.md/apply/html'
    .then (response)->
      expect response.text
      .includes '<table'

  describe.skip 'apply uses a custom template', ->
    it 'can use mappers defined in that directory', ->
      r.get '/files/test/artifacts/dict.json/apply/pug,template:/files/test/artifacts/table.pug'
      .then (response)->
        expect response.text
        .includes '<table'

    it 'use mappers defined in that directory', ->
      r.get '/files/test/artifacts/dict.json/apply/.table.pug'
      .then (response)->
        expect response.text
        .includes '<table'

    it 'image to html', ->
      r.get '/files/test/artifacts/image.jpg/apply/html'
      .then (response)->
        expect response.text
        .includes '<img'