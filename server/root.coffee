{mappers, reducers} = require '../lib'

handlers = require './handlers'

root =
  handlers: handlers
  mappers: mappers.all    # DEBUG: do we want this?

  reducers: reducers

  measures:
    uptime: (req, res)-> req.data = process.uptime()

  metrics:
    uptime:
      period: '10s'
      measure: '/measures/uptime'
    load:
      frequency: 1
      measures: '/requests/logs/entries/reduce/count'

# Object.assign handlers,
#   transformers: handlers.transform.all


Object.assign root, handlers
Object.assign root, mappers

module.exports = root