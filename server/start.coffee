express = require 'express'
app = express()
port = 3000
log = require '@vonholzen/log'

app.get('/', (req, res) => res.send('Hello World!'))

app.listen port, ->
  log 'server listening', {port}
