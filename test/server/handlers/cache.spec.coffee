server = require '../../../server/'
request = require 'supertest'

# test ordering based on known dependencies of `apply`
require '../../stream.spec'
require '../../streams/transformers.spec'

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
