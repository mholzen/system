lib = require '../lib'
streams = require '../streams'
handlers = require './handlers'

generators = Object.assign {}, lib.generators, streams.generators.all
mappers = lib.mappers.all
reducers = lib.reducers.all
transformers = streams.transformers.all

root =
  handlers: handlers
  mappers: mappers    # DEBUG: do we want this?
  generators: generators
  reducers: reducers
  transformers: transformers

  functions:
    generators: generators
    mappers:
      streams: transformers
      any: mappers
      asyn: mappers
    reducers: reducers
    handlers: handlers

  metrics:
    uptime:
      period: '10s'
      measure: '/measures/uptime'
    load:
      frequency: 1
      measures: '/requests/logs/entries/reduce/count'

  root2:
    description: "clean root"
    handlers:
      apply: handlers.apply
      transform: handlers.transform
    functions:
      generators: generators
      mappers:
        stat: mappers.stat
      reducers:
        count: reducers.count
        augment: mappers.augment

Object.assign root, handlers

module.exports = root
