{mappers, reducers} = require '../lib'
{generators, transformers} = require '../streams'

handlers = require './handlers'
os = require 'os'

root =
  handlers: handlers
  mappers: mappers.all    # DEBUG: do we want this?
  generators: generators.all
  reducers: reducers.all
  transformers: transformers.all

  functions:
    generators: generators.all
    mappers:
      streams: transformers.all
      any: mappers.all
      asyn: mappers.all
    reducers: reducers.all

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
      generators:
        homedir: mappers.os.homedir
      mappers:
        stat: mappers.stat
      reducers:
        count: reducers.count
        augment: mappers.augment

Object.assign root, handlers

module.exports = root
