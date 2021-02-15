stream = require '../../lib/stream'

create = (path, options)->
  if not path?
    throw new Error 'no path to get'

  if typeof path == 'string'
    # find column
    column = undefined
    return (data) ->
      data.flatMap (x)->
        # log.debug {column, x}
        if not x?
          return []

        if path of x
          return [ x[path] ]

        # if not column?
        #   log.debug {path, v: x[path], column}
        #   if x[path] == column
        #     column = path
        #     return []
        return []

  throw new Error "can't make getter from '#{path}', #{typeof path}"

get = (data, path, options)->(create path, options) data

get.create = create

module.exports = get