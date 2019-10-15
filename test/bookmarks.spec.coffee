bookmarks = require '../lib/bookmarks'
{query} = require '../lib'

describe 'bookmarks', ->
  it 'iterator', ->
    bookmarks.read.then ->
      expect(bookmarks.items.length).above 500

  it 'query', ->
    matches = query(/google/).match bookmarks.read
    values = await matches[0].value
    expect(values).length.above 20
