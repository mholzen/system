require '../../server.spec'

server = require 'server'
request = require 'supertest'

r = null

describe 'integration', ->
  beforeEach ->
    s = new server.Server()
    r = request s.app

  describe.only 'navigate directories', ->
    it 'works', ->
      r.get '/files/test/artifacts/map/link/reduce/html'
      .then (response)->
        expect response.text
        .includes '<a href='
