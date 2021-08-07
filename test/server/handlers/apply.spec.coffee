server = require '../../../server/'
request = require 'supertest'

# test ordering
require '../handlers.spec'

r = null

beforeEach ->
  s = new server.Server()
  r = request s.app

describe 'servers/handlers/apply', ->
  it 'literal to html', ->
    r.get '/literals/123/apply,mappers.html'
    .then (response)->
      expect response.text
      .includes '<p>123</p>'

  it 'find a mapper by name', ->
    r.get '/literals/123/apply,mappers.isLiteral'
    .then (response)->
      expect response.text
      .includes 'true'

  it 'find a mapper by path', ->
    # TODO: can mappers be referenced by a path?
    # TODO: distinguish between
    # .../apply,mappers.name,option1
    # .../apply,mappers.path,name,option1
    # .../apply,mappers.path,name
    r.get '/literals/graph/apply,mappers.templates.es6'
    .then (response)->
      expect response.text
      .includes 'graph'


  it.skip 'apply finds root item over instance function', ->
    r.get '/mappers/apply,mappers.mappers,html'      # /mappers/apply,mappers.html calls function mappers.html()
    .expect 200 # processed the root document

  it 'markdown to html', ->
    r.get '/files/test/artifacts/blurb.md/apply,mappers.html'
    .then (response)->
      expect response.text
      .includes '<table'

  describe 'apply uses a custom template', ->
    it 'use template data as option', ->
      p = '/literals/a:1/apply,mappers.args/apply,reducers.inject,p %23{options.a}' # ERROR: splits against '.'
      log {p}
      r.get p
      .then (res)->
        expect res.text
        .eql '<p>1</p>'

    it 'use mappers defined in that directory', ->
      r.get '/files/test/artifacts/dict.json/apply,mappers.parse/apply,reducers.inject,.files.test.artifacts.table.pug'
      .then (response)->
        expect response.text
        .includes '<table>'
        .includes '<td>1</td>'
        .includes '<td>2</td>'

    it 'image to html', ->
      r.get '/files/test/artifacts/image.jpg/apply,mappers.html'
      .then (response)->
        expect response.text
        .includes '<img'

  describe 'data function that takes an argument', ->
    it 'sort', ->
      r.get '/literals/c,b,a/apply,mappers.sort'
      .then (res)->
        expect res.text
        .eql '["a","b","c"]'

