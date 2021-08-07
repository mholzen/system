{router} = require 'server'
root = require 'server/root'
get = router.get

mockReq = (path)->
  {
    path
    params: {}
    args: null
    root
  }

describe 'router', ->

  describe 'arguments', ->
    it 'arrays', ->
      r = new router.TreeRouter()
      req = mockReq '/literals/a,b,c'
      res =
        status: ->
          send: ->
            throw new Error arguments...
      r.processPath req, res
      .then (response)->
        expect req.data
        .eql ['a','b','c']

    it 'args mapper', ->
      r = new router.TreeRouter()
      req = mockReq '/literals/a:1/apply,mappers.args/apply,mappers.get,options/apply,reducers.inject,p #{a}'
      res =
        status: ->
          send: ->
            throw new Error arguments...

      r.processPath req, res
      .then (response)->
        expect req.data
        .eql '<p>1</p>'

    it.skip 'template location', ->
      r = new router.TreeRouter()
      req = mockReq '/literals/a:1/apply,mappers.pug,template.location:(/files/test/artifacts/template.pug)'  # template is the data or the ref to data
      res =
        status: ->
          send: ->
            throw new Error arguments...

      r.processPath req, res
      .then (response)->
        expect req.data
        .eql '<p>1</p>'

  describe.skip 'parens', ->
    it 'works', ->
      request.get '/literals/(/literals/1)', ->
      .then (response)->
        expect response.text
        .eql 1
