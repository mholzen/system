express = require 'express'
log = require '../lib/log'
_ = require 'lodash'
isPromise = require 'is-promise'

{stream, mappers, searchers, reducers, generators, inodes} = require '../lib'
{isStream} = stream
content = mappers.content
keys = generators.keys

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

  log.debug 'returning', {resource, context, first}
 
  return resource


root =
  mappers: mappers

  reducers: reducers

root = Object.assign root, require './handlers'

class TreeRouter
  constructor: (aRoot, options)->
    @root = aRoot ? root
    @options = options
    log.debug 'new TreeRouter', {root: @root, options: @options}

    @regexp = new RegExp '/*([^/]*)(.*)'

  process: (req, res, next)->
    req.data = @root
    try
      await @processPath req, res, next
      if req.data? and (not res.headersSent)
        await @respond req, res
    catch err
      log.debug 'process.error', {path: req.path, err: err.stack}
      res.type 'text/plain'
      .status 500
      .send err.stack
    next()

  respond: (req, res)->
    if not req.data?
      res.status 404
      return res.send @root

    req.data = await req.data
    log.debug 'respond', {data: 'typeof-' + typeof req.data}
    if typeof req.data == 'number'
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
      if req.data instanceof Buffer
        # streamable?
        return res.send(req.data.toString())

      if isStream req.data
        log.debug 'respond with stream'
        # streamable?
        # req.data.pipe res
        # return res.end

        data = await req.data.collect().toPromise Promise
        return res.send data

      if not isStream req.data
        log.debug 'respond', {data: req.data}
        req.data = mappers.json req.data
        res.type 'application/json'

    if typeof req.data == 'string'
      return res.send req.data

    if not isStream req.data
      req.data = keys req.data

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

      # log.debug 'processPath', {remainder: req.remainder, req_data: req.data}

      first = req.remainder.shift()
      if not first?
        log.debug 'empty first'
        return res.status(404).send('empty first path element')

      if not (first?.length > 0)
        log.debug 'no more paths. about to send response', {first, remainder: req.remainder}
        break

      if isPromise req.data
        req.data = await req.data

      target = =>
        if (typeof req.data == 'object') and (req.data.hasOwnProperty first)
          return req.data[first]
        if (first of @root)
          return @root[first]

      target = target()
      if not target
        return res.status(400).send("cannot find '#{first}' in req.data of '#{log.print req.data}' nor in root")

      if typeof target == 'function'
        log.debug 'calling handler', {name: first}
        await target req, res, @
        continue

      if typeof target != 'object'
        return res.status(500).send "lookup in non-object"

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
