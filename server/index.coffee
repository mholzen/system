express = require 'express'
log = require '../lib/log'
router = require './router'

class Server
  constructor: (options)->
    @app = express()
    @port = options?.port ? 3000
    @rewrites = options?.rewrites
    if @rewrites?
      @app.use (req, res, next)=>
        # log.debug 'router.process pre-rewrite', {url: req.url}
        if req.url of @rewrites
          req.url = @rewrites[req.url]
        # log.debug 'router.process post-rewrite', {url: req.url}
        next()
    @rewriteRules = options?.rewriteRules
    if @rewriteRules?
      @app.use (req, res, next)=>
        for rule in @rewriteRules
          if rule[0].test req.url
            log.debug 'rewrite.pre', {url: req.url}
            req.url = req.url.replace rule[0], rule[1]
            log.debug 'rewrite.post', {url: req.url}
        next()

    @app.use router()

  listen: (cb) ->
    # turn to promise
    @app.listen @port, cb

server = (options)->
  new Server options

server.Server = Server
server.router = router

module.exports = server
