stream = require '../../lib/stream'

flatMapper = (path, options)->
  # returns a mapper.get that uses the first row as containing column names 

  if not path?
    throw new Error 'no path to get'

  if typeof path == 'string'
    # find column
    columnNo = undefined
    return (x)->
      if not x?
        return []
      if typeof x == 'object'
        if path of x
          return [ x[path] ]

        if not columnNo?
          # find column number given path
          # assumes first data element were headers
          if (columnNo = x.indexOf path) > 0
            # path found in header, return nothing
            return []
          else
            # path not found in header, also return nothing
            return []
          
        if columnNo of x
          return [ x[columnNo] ]

      return []

  throw new Error "can't make getter from '#{path}', #{typeof path}"

create = (path, options)->
  f = flatMapper path, options
  (input) -> input.flatMap f     

get = (data, path, options)->(create path, options) data

get.create = create
get.flatMapper = flatMapper

module.exports = get