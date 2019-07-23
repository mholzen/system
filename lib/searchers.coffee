query = require './query'
bookmarks = require './bookmarks'
inodes = require './inodes'
urlQueries = require './urlQueries'
mappers = require './mappers'
reducers = require './reducers'

searchers = {
  urlQueries
  bookmarks
  inodes: inodes()
  templates: {name: 'templates', path:/\.hbs$/}
  mappers: {name: 'mappers', mappers, items: Object.keys mappers}
  reducers: {name: 'reducers', reducers, items: Object.keys reducers }
}

searchers.all = Object.values searchers

searchers.read =
  Promise.all [ bookmarks.read ]
  .then -> searchers.all

searchers.search = (args...)->
  query(args).searchIn searchers.all

module.exports = searchers
