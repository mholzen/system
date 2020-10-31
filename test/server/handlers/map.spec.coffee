server = require '../../../server/'
request = require 'supertest'

# TODO: why do we need these here?
require '../../stream.spec'    # test ordering based on dependencies
require '../../streams/transformers.spec'    # test ordering based on dependencies

r = null

describe 'servers/handlers/map', ->
  before ->
    s = new server.Server()
    r = request s.app

  it 'map resolves converts string to function', ->
    r.get '/literals/1,3,5/map/augment,increase,name:increment'
    .then (response)->
      expect response.text
      .includes '1'
      .includes '2'
      .includes '3'
      .includes '4'
      .includes '5'
      .includes '6'