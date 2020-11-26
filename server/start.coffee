#!/usr/bin/env coffee

server = require '../server'
log = require '../lib/log'

s = new server.Server
  port: 3001
  rewriteRules: [
    [/\/team(\/|$)/, '/files/test/artifacts/marchome/data/people/my-team/Graph']
    [/\/Graph(\/|$)/, '/reduce/graph/apply/dict,name:graph/apply/template,template:name:Graph']
    [/\/Graph2(\/|$)/, '/apply/parse/apply/graph/apply/dict,name:graph/apply/template,template:name:Graph/type/html']
    [/\/directory(\/|$)/, '/map/object,name:name/map/augment,req.dirname,name:directory/map/augment,req.base,name:base/map/augment,stat,name:stat/apply/resolve/map/link/apply/html,style:name:thumbnails']
    [/\/Book(\/|$)/, '/index.pug/apply/pug/apply/html,style:url:book-light.css']
  ]

process.on 'unhandledRejection', (error) =>
  console.log 'unhandledRejection', error

s.listen (err)->
  if err
    log.error err
  else
    log.debug 'started', {port: s.port}
