server = require 'server'
request = require 'supertest'

r = null

describe 'servers/handlers/files', ->
  before ->
    s = new server.Server()
    r = request s.app

  it 'accepts root as input', ->
    r.get '/apply,os,homedir/files'
    .then (response)->
      expect response.text
      .includes '.bash'
