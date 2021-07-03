{mappers, reducers} = require '../lib'

handlers = require './handlers'
os = require 'os'

root =
  handlers: handlers
  mappers: mappers.all    # DEBUG: do we want this?

  reducers: reducers

  metrics:
    uptime:
      period: '10s'
      measure: '/measures/uptime'
    load:
      frequency: 1
      measures: '/requests/logs/entries/reduce/count'

Object.assign root, handlers

module.exports = root