stream = require 'highland'
log = require '@vonholzen/log'

{bookmarks} = require './lib/bookmarks'
dates = require './lib/dates'
{Stat} = require './lib/inodes'
# require './lib/application'
# require './lib/json'
# require './lib/urlQueries'
# require './lib/url'
# require './lib/sql'
# require './lib/sparql'

searchers = [
  # bookmarks
  # dates
  new Stat()
]

module.exports = searchers
