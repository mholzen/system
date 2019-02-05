JSONPath = require 'JSONPath'
fs = require 'fs'
_ = require 'lodash'
log = require '@vonholzen/log'
stream = require 'highland'

# TODO: move to parser?

class JsonFile
  constructor: (filename, path, generator)->
    @filename = filename
    @path = path
    @generator = generator
    @items = stream()
    @name = 'bookmarks'

    fs.readFile @filename, 'utf8', (err, data)=>
      if err
        console.error err
        return

      JSONPath
        json: JSON.parse data
        path: @path
        flatten: true
        callback: (item)=>
          log 'jsonfile reading item', {item}
          @items.write @generator item

  toString: ->
    JSON.stringify
      path: @path
      name: @name

bookmarksFile = process.env.HOME + '/Library/Application Support/Google/Chrome/Default/Bookmarks'

bookmarks = new JsonFile bookmarksFile, '$..[?(@.url)]', (i)->
  log 'bookmarks read bookmark', {i}
  i.toString = -> i.name + ' ' + i.url
  i

module.exports = bookmarks
