express = require 'express'
log = require '@vonholzen/log'
app = express()
port = 3000
router = require './router'

app.use router()

app.listen port, ->
  log 'server listening', {port}
