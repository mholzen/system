bookmarks = require '../lib/bookmarks'

describe 'bookmarks', ->
  it 'iterator', (done)->
    bookmarks.items.take(10).toArray (items)->
      expect(items).property('length').equal(10)
      done()
