#!/usr/bin/env coffee

server = require '../server'
log = require '../lib/log'

s = new server.Server
  port: 3001
  rewriteRules: [
    [/\/Graph(\/|$)/, '/reduce/graph/apply/dict,name:graph/apply/template,template:name:Graph']
    [/\/directory(\/|$)/, '/map/object,name:name/map/augment,req.dirname,name:directory/map/augment,req.base,name:base/map/augment,stat,name:stat/apply/resolve/map/link/apply/html,style:name:thumbnails']
  ]

process.on 'unhandledRejection', (error) =>
  console.log 'unhandledRejection', error

s.listen (err)->
  if err
    log.error err
  else
    log.debug 'started', {port: s.port}
