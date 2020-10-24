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

  # TODO: mapper.augment = (data, functionOrString, options)->
  # how do we distinguish between function and string for second argument?

  # option 1: force 2nd argument to be a function.  use a literal function to pass a string
  # option 2: we search functions first

  it 'map resolves converts string to function', ->
    r.get '/literals/a,b,c/map/augment,html'
    .then (response)->
      expect response.text
      .includes '<p>123</p>'
