file = require '../lib/file'

types = ['application']
module.exports =
  types: types
  head: (query)-> types.includes query?.type

  search: (query, out)->
    return if query.type? and not types.includes query.type

    if query.depth == 0
      out.write this
      out.end
      return

    file.search
      in: '/Applications'
      name: new RegExp (query.name ? '') + '.*\.app', 'i'
      type: 'directory'
      recurse: false
    , out
