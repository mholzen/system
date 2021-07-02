log = require '../../lib/log'
{append} = require '../../lib/mappers'

class RequestLogs
  constructor: (size)->
    @size = size ? 10
    @entries = []

  add: (req)->
    @entries.unshift {path: req.path, timestamp: Date.now()}
    if @entries.length > @size
      @entries.pop()
    @entries[0]

create = (options)->
  logs = new RequestLogs()

  (req, res)->
    logs.add req
    log 'appending'
    append req
    # next()
    req.data

module.exports = create()
