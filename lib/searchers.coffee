stream = require 'highland'
log = require '@vonholzen/log'

{bookmarks} = require './bookmarks'
dates = require './dates'
inodes = require './inodes'
# require './lib/application'
# require './lib/json'
urlQueries = require './urlQueries'
# require './lib/url'
# require './lib/sql'
# require './lib/sparql'

searchers = {
  bookmarks
  urlQueries
  dates
  inodes
}

module.exports = searchers
