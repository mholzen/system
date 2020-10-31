server = require '../../../server/'
request = require 'supertest'

require '../../stream.spec'    # test ordering based on dependencies
require '../../streams/transformers.spec'    # test ordering based on dependencies

r = null

describe 'servers/handlers/literals', ->
  before ->
    s = new server.Server()
    r = request s.app

  it '/literals/123', ->
    r.get '/literals/123'
    .then (response)->
      expect response.text
      .includes '123'

  it '/literals/a,b,c', ->
    r.get '/literals/a,b,c'
    .then (response)->
      expect response.text
      .includes '['