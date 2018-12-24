{search} = require '../lib'

describe 'search', ->
  it 'should find top level', (done)->
    search(null).toArray (results)->
      expect(results).length.above(0)   # files, urls, urlQueries
      log 'test', {results}
      done()
