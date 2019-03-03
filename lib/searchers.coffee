bookmarks = require './bookmarks'
inodes = require './inodes'
urlQueries = require './urlQueries'
# require './lib/application'
# require './lib/url'
# require './lib/sql'
# require './lib/sparql'
mappers = require './mappers'
reducers = require './reducers'

searchers = {
  bookmarks
  urlQueries
  inodes: inodes()
  templates: {name: 'templates', path:/\.hbs$/}
  mappers: {name: 'mappers', mappers, items: Object.keys mappers}
  reducers: {name: 'reducers', reducers, items: Object.keys reducers }
}

searchers.all = Object.values searchers

module.exports = searchers
