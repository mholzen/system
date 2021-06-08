{router} = require 'server'
get = router.get

describe 'router', ->

  describe 'arguments', ->
    it 'arrays', ->
      r = new router.TreeRouter()
      req =
        path: '/literals/a,b,c'
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
      req =
        path: '/literals/a:1/apply/args/apply/pug,template:p #{options.a}'
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
      req =
        path: '/literals/a:1/apply/pug,template.location:(/files/test/artifacts/template.pug)'  # template is the data or the ref to data
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


describe 'get', ->
  context =
    a: 1
    b: (data)-> data.length
    c:
      a: 2

  it 'with no path should return data', ->
    r = await get 'abc'
    expect(r).equal 'abc'

  it 'with object and path returns that property of the object', ->
    r = await get(a:2, 'a')
    expect(r).equal 2

  it 'with a non-existing path in data should return context', ->
    r = await get('abc', 'a', context)
    expect(r).equal 1

  it.skip 'with a function name in data should return context', ->
    r = await get('abc', 'f', {f: (v)->v.length })
    expect(r).equal 3

  it 'with a function name in data should return context', ->
    r = await get('abc', 'c', context)
    expect(r).eql a: 2
