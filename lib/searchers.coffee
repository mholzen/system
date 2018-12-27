stream = require 'highland'
log = require '@vonholzen/log'

{bookmarks} = require './bookmarks'
inodes = require './inodes'
urlQueries = require './urlQueries'
# require './lib/application'
# require './lib/json'
# require './lib/url'
# require './lib/sql'
# require './lib/sparql'

searchers = {
  bookmarks
  urlQueries
  inodes
}

module.exports = searchers
