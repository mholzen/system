urlQueries = require '../lib/urlQueries'
mappers = require '../lib/mappers'
stream = require '../lib/stream'

describe 'urlQueries', ->

  it 'should generate an url', ->
    data = query: 'string'

    mapper = mappers.template 'http://foo.com/#{query}'
    expect(mapper data).eql 'http://foo.com/string'

  it 'should get content', ->
    google = urlQueries.google
    result = await mappers.content google, stream [query: 'foo']
    result.toArray (r)->
      expect(r[0]).eql 'http://google.com/search?q=foo'
