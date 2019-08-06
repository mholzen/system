bookmarks = require './bookmarks'
inodes = require './inodes'
urlQueries = require './urlQueries'
mappers = require './mappers'
reducers = require './reducers'
log = require './log'

log.debug 'foo', Object.keys mappers
searchers = {
  urlQueries
  bookmarks
  inodes: inodes().items
  templates: {name: 'templates', path:/\.hbs$/}
  mappers: {name: 'mappers', mappers, items: Object.keys mappers}
  reducers: {name: 'reducers', reducers, items: Object.keys reducers }
}

searchers.read =
  Promise.all [ bookmarks.read ]
  .then -> searchers

module.exports = searchers
