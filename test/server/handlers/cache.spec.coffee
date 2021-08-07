server = require '../../../server/'
request = require 'supertest'

# test ordering
require '../handlers.spec'

r = null

describe 'servers/handlers/cache', ->
  before ->
    s = new server.Server()
    r = request s.app

  it 'cache a request', ->
    r.get '/cache/literals/123'
    .then (response)->
      expect response.text
      .includes '123'
