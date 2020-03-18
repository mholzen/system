#!/usr/bin/env coffee

server = require '../server'
log = require '../lib/log'

s = new server.Server
  port: 3001

s.listen (err)->
  if err
    log.error err
  else
    log.debug 'started', {port: s.port}