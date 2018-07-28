{search} = require '../lib'

describe 'search', ->
  it 'returns a stream', ->
    results = search 'abc'
    expect(typeof results.head == 'function').true

  it.skip 'returns top level resources', (done)->
    results = search 'abc', 'recurse:false'

    results.toArray (results)->
      expect(results).length.above(0)   # files, urls, urlQueries
      done()
