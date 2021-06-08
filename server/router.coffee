{stream, mappers, reducers, streams} = require '../lib'
{NotFound} = require '../lib/errors'

handlers = require './handlers'
Pipe = require './pipe'

{ReadStream} = require 'fs'
{isStream} = stream
{Arguments} = mappers.args

express = require 'express'
log = require '../lib/log'
_ = require 'lodash'
isPromise = require 'is-promise'
{join, sep} = require 'path'

id = (obj)->
  if typeof obj.path == 'string'
    return obj.path
  obj

get = (data, path, context)->
  if not (path?.length > 0)
    return data

  matches = path.match new RegExp '/*([^/]*)(.*)'
  if not (matches?[1]?.length > 0)
    return data

  [, first, remainder] = matches
  resource = _.get data, first

  if not resource?
    resource = _.get context, first

  # log.debug 'returning', {resource, context, first}
 
  return resource

parse = (path)->
  words = path.split '/'
  (word.split ',' for word in words)

root =
  handlers: handlers
  mappers: mappers.all    # DEBUG: do we want this?

  reducers: reducers

  measures:
    uptime: (req, res)-> req.data = process.uptime()

  metrics:
    uptime:
      period: '10s'
      measure: '/measures/uptime'
    load:
      frequency: 1
      measures: '/requests/logs/entries/reduce/count'

Object.assign handlers,
  transformers: handlers.transform.all

Object.assign root, handlers

class RewriteRouter
  constructor: (rewrites)->
    @rewrites = rewrites
  process: (req, res)->
    if @rewrites?
      # log.debug 'router.process pre-rewrite', {url: req.url}
      if req.url of @rewrites
        req.url = @rewrites[req.url]
      # log.debug 'router.process post-rewrite', {url: req.url}

    if @rewriteRules?
      for rule in @rewriteRules
        if rule[0].test req.url
          # log.debug 'rewrite.pre', {url: req.url}
          req.url = req.url.replace rule[0], rule[1]
          # log.debug 'rewrite.post', {url: req.url}

class RequestLogs
  constructor: (size)->
    @size = size ? 10
    @entries = []
  add: (req)->
    @entries.unshift {path: req.path, timestamp: Date.now()}
    if @entries.length > @size
      @entries.pop()
    @entries[0]

class TreeRouter
  constructor: (aRoot, options)->
    @root = aRoot ? root
    @options = options
    # log.debug 'new TreeRouter', {root: @root, options: @options}

    @logs = new RequestLogs()
    @root.requests =
      logs: @logs

    if options?.rewrites?
      @rewriter = new RewriteRouter options.rewrites
      @root.rewrites = options.rewrites

  process: (req, res, next)->
    # log.debug 'TreeRouter.process', {d: req.data}
    req.log = @logs.add req   # Warning: dirty `req`
    req.root = @root
    req.data = @root
    if @rewriter
      @rewriter.process req, res, next
    try
      await @processPath req, res, next
      if req.data? and (not res.headersSent)
        await @respond req, res
    catch err
      # log.debug 'process.error', {path: req.path, err: err.stack}
      if err.send?
        err.send res
      else
        res.type 'text/plain'
        .status 500
        .send err.stack

    if not req.data?
      res.status 404
      .send 'req.data is not defined'
      return

    log.debug 'next'
    next()

  respond: (req, res)->
    req.data = await req.data
    # log.debug 'respond', {data:req.data}

    if ['boolean', 'number'].includes typeof req.data
      req.data = req.data.toString()

    if req.data instanceof Buffer
      return res.send req.data

    if typeof req.data == 'function'
      data = req.data.apply()
      if isStream data
        return res.send await data.collect().toPromise Promise

      return res.send data
      # return res.type('text/plain').send 'function with properties: ' + Object.getOwnPropertyNames(req.data).join(',')

    if typeof req.data == 'object'

      if (req.data instanceof ReadStream) or (req.data._readableState?)
        log.debug 'router.respond: piping data'
        s = req.data.pipe res
        return new Promise (resolve)->
          s.on 'finish', ->
            resolve()

      if req.data instanceof Buffer
        # streamable?
        return res.send req.data.toString()

      if isStream req.data
        # log.debug 'respond with stream'
        # streamable?
        # req.data.pipe res
        # return res.end
        errorsAsData = (err, push)->
          # log.error 'stream.send', {err}
          push null, err
        req.data = await req.data.errors(errorsAsData).collect().toPromise Promise

      if not isStream req.data
        # log.debug 'respond', {data: req.data}
        req.data = mappers.json req.data
        res.type 'application/json'

    if typeof req.data == 'string'
      return res.send req.data

    if not isStream req.data
      req.data = Object.keys req.data

    # log.debug {data: req.data}
    data = await reducers.reduce req.data.map(id), 'html'
    .toPromise Promise

    res.send data

  processPath: (req, res, next)->
    if not req.remainder?
      if req.path[0] != '/'
        throw new Error "path doesn't start with / #{log.print req.path}"
      if req.path == '/'
        res.status 200
        req.data = @root
        return

      decodedPath = decodeURI req.path
      req.remainder = decodedPath.substr(1).split '/'

    # log.debug 'processPath', {path: req.path, remainder: req.remainder}
    while req.remainder?.length > 0

      # log.debug 'processPath', {remainder: req.remainder, data: req.data}

      segment = req.remainder.shift()
      if not segment?
        # log.debug 'empty segment'
        continue

      if segment.length == 0
        # log.debug 'trailing(or empty) slash', {data: req.data}
        # return req.data as a collection
        toCollection = (data)->
          if Array.isArray data
            return data
          if typeof data?.entries == 'function'
            return data.entries()
          if typeof data?.keys == 'function'
            return data.keys()
          if data?.values == 'function'
            return data.values()
          Object.keys data
        req.data = await toCollection req.data
        continue

      req.args = Arguments.from segment
      first = req.args.first()
      if req.args.positional.length > 0
        req.args.positional.shift()

      if isPromise req.data
        req.data = await req.data

      find = (data, first, root) =>
        if (typeof data == 'object') and (data.hasOwnProperty first)
          # DEBUG: when first=mappers, it returns the mappers creator function
          # option 1: creator functions are handled differently
          # log.debug 'found first in data', {first}
          return data[first]
        if (first of root)
          # log.debug 'found first in root', {first}
          return root[first]
        throw new NotFound first, data, root

      target = find req.data, first, @root

      if typeof target == 'function'
        # log.debug 'calling handler', {name: first}
        # DEBUG: when req.data=/mappers, target calls the mappers() function here
        await target req, res, @
        continue

      if target instanceof Array
        pipe = new Pipe target, @root
        return pipe.process req, res, next

      req.data = target

router = (options)->
  r = new express.Router()
  treeRouter = new TreeRouter root, options
  r.use treeRouter.process.bind treeRouter
  r

router.TreeRouter = TreeRouter
router.root = root
router.get = get

module.exports = router