fs = require 'fs'
_ = require 'lodash'
log = require '../lib/log'
stream = require 'highland'
{promisify} = require 'util'
readFile = promisify fs.readFile
jsonpath = require 'jsonpath'

# TODO: move to parser?

class JsonFile
  constructor: (filename, path)->
    @filename = filename
    @path = path
    @read = readFile @filename, 'utf8'
    .then (data)=>
      data = JSON.parse data
      @items = jsonpath.query data, @path
      return @items

bookmarksFile = process.env.HOME + '/Library/Application Support/Google/Chrome/Default/Bookmarks'

bookmarks = new JsonFile bookmarksFile, '$..[?(@.url)]'

module.exports = bookmarks
