server = require '../../../server/'
request = require 'supertest'

require '../../stream.spec'    # test ordering based on dependencies
require '../../streams/transformers.spec'    # test ordering based on dependencies

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
  
  it.skip 'apply finds root item over instance function', ->
    r.get '/mappers/apply/mappers,html'      # /mappers/apply/html calls function mappers.html()
    .expect 200 # processed the root document

  it '/files/test/artifacts/blurb.md/apply/html', ->
    r.get '/files/test/artifacts/blurb.md/apply/html'
    .then (response)->
      expect response.text
      .includes '<table'

  describe 'apply uses a custom template', ->
    it 'use template data as option', ->
      #r.get encodeURI '/literals/a:1/apply/args/apply/pug,template:p %23{a}'
      r.get encodeURI '/literals/a:1/apply/args/apply/pug,template:p'
      .then (res)->
        expect res.text
        # .eql '<p>1</p>'
        .eql '<p></p>'

    it 'use mappers defined in that directory', ->
      r.get '/files/test/artifacts/dict.json/generators/parse/apply/pug,template:path:table.pug'
      .then (response)->
        expect response.text
        .includes '<table>'
        .includes '<td>1</td>'
        .includes '<td>2</td>'

    it 'image to html', ->
      r.get '/files/test/artifacts/image.jpg/apply/html'
      .then (response)->
        expect response.text
        .includes '<img'

  describe 'data function that takes an argument', ->
    it 'sort', ->
      r.get '/literals/c,b,a/apply/sort'
      .then (res)->
        expect res.text
        .eql '["a","b","c"]'
