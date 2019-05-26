bookmarks = require '../lib/bookmarks'

describe 'bookmarks', ->
  it 'iterator', ->
    bookmarks.read.then ->
      expect(bookmarks.items.length).above 500
