server = require '../../../server/'
request = require 'supertest'

# test ordering
require '../handlers.spec'

r = null

describe 'servers/handlers/reduce', ->
  before ->
    s = new server.Server()
    r = request s.app

  it.skip '/files/test/artifacts/reduce/html', ->
    r.get '/files/test/artifacts/reduce/html,style:name:pretty'
    .then (response)->
      expect response.text
      .includes '<style type="css/rel" href="pretty"/>'
