express = require 'express'
log = require '@vonholzen/log'
{mappers, searchers} = require '../lib'
{keys} = require '../lib/generators'

app = express()
port = 3000

root = {mappers, searchers}

streamResponse = (req, res)->
  keys(req.data).toArray (array)->
    res.send array.join "\n"

app.get '/', (req, res) ->
  req.data = root
  streamResponse req, res

app.get '/mappers', (req, res) ->
  req.data = mappers
  streamResponse req, res

app.get '/searchers', (req, res) ->
  req.data = searchers
  streamResponse req, res

app.listen port, ->
  log 'server listening', {port}
