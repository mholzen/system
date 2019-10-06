fs = require 'fs'
_ = require 'lodash'
log = require '../lib/log'
stream = require 'highland'
{promisify} = require 'util'
readFile = promisify fs.readFile
jsonpath = require 'jsonpath'

# TODO: move to parser?

class JsonFile
  constructor: (filename, path, generator)->
    @filename = filename
    @path = path
    @generator = generator
    @name = 'bookmarks'
    @read = readFile(@filename, 'utf8').then (data)=>
      data = JSON.parse data
      @items = jsonpath.query data, @path
      return @

  entries: ->
    stream (push, next)=>
      await @read
      for item in @items
        push null, item
      push null, stream.nil

  toString: ->
    JSON.stringify
      path: @path
      name: @name

bookmarksFile = process.env.HOME + '/Library/Application Support/Google/Chrome/Default/Bookmarks'

bookmarks = new JsonFile bookmarksFile, '$..[?(@.url)]', (i)->
  i.toString = -> i.name + ' ' + i.url
  i

module.exports = bookmarks
