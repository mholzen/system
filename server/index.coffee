express = require 'express'
log = require '../lib/log'
router = require './router'

class Server
  constructor: (options)->
    @app = express()
    @port = options?.port ? 3000
    @app.use router()

  listen: (cb) ->
    # turn to promise
    @app.listen @port, cb

server = (options)->
  new Server options

server.Server = Server
server.router = router

module.exports = server
