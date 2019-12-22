bookmarks = require '../lib/bookmarks'
{query} = require '../lib'

require './query.spec'

describe 'bookmarks', ->
  it 'iterator', ->
    bookmarks.read.then ->
      expect(bookmarks.items.length).above 500

  it 'query', ->
    matches = await query(/google/).match bookmarks.read
    expect(matches).length.above 20
