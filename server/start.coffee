#!/usr/bin/env coffee

server = require '../server'
log = require '../lib/log'
logHandler = require './handlers/log'

s = new server.Server
  port: 3001
  rewriteRules: [
    # TODO: refactor into pipes to:extensible
    [/\/team(\/|$)/, '/files/test/artifacts/marchome/data/people/my-team/Graph']
    [/\/Graph(\/|$)/,  '/reduce/graph/apply,mappers.dict,name:graph/apply,mappers.template,template:name:Graph']
    [/\/Graph2(\/|$)/, '/reduce/graph/apply,mappers.dict,name:graph/apply,mappers.template,template:name:Graph2']
    [/\/Graph3(\/|$)/, '/apply,mappers.parse/apply,mappers.graph/apply,mappers.dict,name:graph/apply,mappers.template,template:name:Graph/type/html']
    [/\/directory(\/|$)/, '/map/object,name:name/map/augment,req.dirname,name:directory/map/augment,req.base,name:base/map/augment,stat,name:stat/apply,mappers.resolve/map/link/apply,mappers.html,style:name:thumbnails']
    [/\/Symlinks(?=\/|$)/,
      [
        '/map/object,name:name'
        'map/augment,req.dirname,name:directory'
        'map/augment,resolve.all.fs.all.readlink,name:symlink'
        'apply,mappers.resolve'
        'transform/filter,string,path:symlink'
      ].join '/'
    ]
  ]

s.app.use logHandler

process.on 'unhandledRejection', (error) =>
  console.log 'unhandledRejection', error

s.listen (err)->
  if err
    log.error err
    return

  log.info 'started', {port: s.port}
