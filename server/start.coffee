express = require 'express'
app = express()
port = 3000
log = require '@vonholzen/log'
{mappers} = require '../lib'


app.get '/mappers', (req, res) ->
  res.send (Object.keys mappers).join "\n"

app.get '/', (req, res) -> res.send 'mappers'

app.listen port, ->
  log 'server listening', {port}
