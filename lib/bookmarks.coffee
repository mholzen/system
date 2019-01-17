JSONPath = require 'JSONPath'
fs = require 'fs'
_ = require 'lodash'
log = require '@vonholzen/log'
stream = require 'highland'

# bookmarks = process.env.HOME + '/Library/Application Support/Google/Chrome/Default/Bookmarks'
#
# types = ['url', 'bookmark']
#
# search = (query, out)->
#   if not (query instanceof Query)
#     query = createQuery query
#
#   return if query.type? and not types.includes query.type
#
#   if query.depth == 0
#     out.write this
#     out.end
#     return
#
#   fs.readFile bookmarks, 'utf8', (err, data)->
#     if err
#       console.error err
#       return
#
#     JSONPath
#       json: JSON.parse data
#       path: '$..[?(@.url)]'
#       flatten: true
#       callback: (bookmark)->
#         bookmark.toString = () -> @name + ' ' + @url
#         if query.test bookmark
#           if query.in? and query.content?
#             bookmark = bookmark + query.content.toString()
#           out.write bookmark
#     out.end()

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
log 'bookmarks reading bookmarks file', {bookmarksFile}
bookmarks = new JsonFile bookmarksFile, '$..[?(@.url)]', (i)->
  log 'bookmarks read bookmark', {i}
  i.toString = -> i.name + ' ' + i.url
  i

module.exports =
  bookmarks: bookmarks
