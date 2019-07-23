urlQueries = require '../lib/urlQueries'
mappers = require '../lib/mappers'
stream = require '../lib/stream'

describe 'urlQueries', ->
  it 'should get content', ->
    google = urlQueries.google
    result = google.substitute query: 'foo'
    expect(result).eql 'http://google.com/search?q=foo'
