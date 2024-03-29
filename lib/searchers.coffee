bookmarks = require './bookmarks'
inodes = require './inodes'
urlQueries = require './urlQueries'
mappers = require './mappers'
reducers = require './reducers'
log = require './log'
_ = require 'lodash'

searchers = {
  inodes: (options)-> inodes(options?.start).entries()
  bookmarks: (options)-> await bookmarks.read
  # applications: directories /Applications/*.app/
  # workflowy: file '~/Dropbox/Apps/Workflowy/Data/(marc@vonholzen.org).#{date()}.workflowy.backup'
}

entries = -> Object.entries searchers

instantiate = (data, options)->
  if typeof data != 'function'
    return data
  data options

get = (options)->
  # new Map entries().map (entry)-> [entry[0], instantiate entry[1], options]
  _.mapValues searchers, (searcher, key)-> searcher options?[key]

get.entries = entries
module.exports = Object.assign get, searchers
