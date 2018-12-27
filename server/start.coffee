express = require 'express'
log = require '@vonholzen/log'
{stream, mappers, searchers, reducers, generators} = require '../lib'
keys = generators.keys
app = express()
port = 3000

root = {mappers, searchers, reducers, generators}

id = (obj)->
  if typeof obj.path == 'string'
    return obj.path
  obj

streamResponse = (req, res)->
  if not stream.isStream req.data
    req.data = keys req.data

  reducers.reduce req.data.map(id), 'html'
  .toArray (r)->
    res.send r[0]

addRoute = (app, prefix, data)->

  console.log 'addRoute', {prefix}
  app.get prefix, (req, res) ->
    req.data = data
    streamResponse req, res

  if not prefix.endsWith '/'
    prefix += '/'

  children = keys data
  if not children?
    return

  children.each (key)->
    if data[key]?
      addRoute app, prefix + key, data[key]

addRoute app, '/', root

app.get '/files', (req, res) ->
  req.data = searchers.inodes().items
  streamResponse req, res

app.listen port, ->
  log 'server listening', {port}
