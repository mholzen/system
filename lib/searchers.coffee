bookmarks = require './bookmarks'
inodes = require './inodes'
urlQueries = require './urlQueries'
# require './lib/application'
# require './lib/url'
# require './lib/sql'
# require './lib/sparql'

searchers = {
  bookmarks
  urlQueries
  inodes: inodes()
}

searchers.all = Object.values searchers

module.exports = searchers
