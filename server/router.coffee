express = require 'express'
log = require '@vonholzen/log'
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


class TreeRouter
  constructor: (root)->
    if not root?
      throw new Error 'missing root data'
    @root = root
    log.debug {root}
    # @rootInode = inodes()
    # throw new Error ('here')
    @regexp = new RegExp '/*([^/]*)(.*)'

  process: (req, res, next)->
    req.data = @root
    # res.type = -> throw new Error()
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
      req.remainder = req.path.substr(1).split '/'

    log.debug 'processPath', {path: req.path, remainder: req.remainder}
    while req.remainder?.length > 0

      log.debug 'processPath', {remainder: req.remainder, req_data: req.data}

      first = req.remainder.shift()
      if not first?
        log.debug 'empty first'
        return res.status(404).send('empty first path element')

      if not (first?.length > 0)
        log.debug 'no more paths. about to send response', {first, remainder: req.remainder}
        break

      target = =>
        if (typeof req.data == 'object') and (req.data.hasOwnProperty first)
          return req.data[first]
        if (first of @root)
          return @root[first]

      target = target()
      if not target
        return res.status(400).send("cannot lookup '#{first}' in req.data of '#{log.print req.data}' nor in root")

      if typeof target == 'function'
        log.debug 'calling handler', {name: first}
        await target req, res, @
        # target req, res, @
        continue

      if typeof target != 'object'
        return res.status(500).send "lookup in non-object"

      req.data = target

root =
  generators: (req, res, router)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      req.data = Object.keys(generators).sort()
      return

    if not (generator = generators[name])
      return res.status(404).send "'#{name}' not found"

    if not req.data?
      return res.status(400).send 'no data'

    if isPromise req.data
      req.data = await req.data

    if req.data instanceof Buffer
      req.data = req.data.toString()

    req.data = generator req.data, {req}
    log.debug 'generator', {output: req.data, name: req.name}
    req.data

  searchers: (req, res, router)->
    name = req.remainder.shift()
    req.data = searchers()
    if not name?  
      return
    if not name in req.data
      return res.status(404).send "'#{name}' not found in #{req.data}"
    req.data = req.data[name]
    
  type: require './handlers/type'

  literals: (req, res)->
    if not (req.remainder?.length > 0)
      throw new Error "no items in req.remainder"

    req.data = req.remainder.shift()
    # log.debug 'literals handler', {data: req.data, remainder: req.remainder}

  apply: (req, res)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      req.data = Object.keys(mappers).sort()
      return

    if not (f = mappers[name])?
      return res.status(404).send "'#{name}' not found"

    if typeof f != 'function'
      req.data = f
      return

    if not req.data?
      return res.status(400).send 'no data'

    # perhaps mapper can handle that?
    if isPromise req.data
      req.data = await req.data

    # if req.data instanceof Buffer
    #   req.data = req.data.toString()

    if req.data instanceof Array
      req.data = stream req.data

    # log.debug 'apply f', {req_data: req.data, f:f}
    args = [ req.data, {filename: req.filename} ] # TODO: how is the second argument defined?
    req.data = f.apply {}, args   

  map: (req, res)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      req.data = Object.keys(mappers).sort()
      return

    if not (f = mappers[name])?
      return res.status(404).send "'#{name}' not found"

    if typeof f != 'function'
      req.data = f
      return

    if not req.data?
      return res.status(400).send 'no data'

    # perhaps mapper can handle that?
    if isPromise req.data
      req.data = await req.data

    if req.data instanceof Buffer
      req.data = req.data.toString()

    if req.data instanceof Array
      req.data = stream req.data

    # log.debug 'apply f', {req_data: req.data, f:f}
    req.data = req.data.map (v)->
      f v, {filename: req.filename} # TODO: how is the second argument defined?

  reduce: (req, res, router)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      req.data = Object.keys(reducers).sort()
      return

    if not (reducer = reducers[name])
      return res.status(404).send "'#{name}' not found"

    if not req.data?
      return res.status(400).send 'no data'

    # perhaps mapper can handle that?
    if isPromise req.data
      req.data = await req.data

    if req.data instanceof Buffer
      req.data = req.data.toString()

    req.data = reducers.reduce req.data, name

  mappers: mappers

  reducers: reducers

  files: (req, res, router) ->
    path = req.remainder ? []
    log.debug 'files entry', {path}
    try
      inodePath = new inodes.Path path
      await inodePath
    catch err
      if err.toString().includes 'ENOENT'
        log.debug 'ENOENT', {path}
        # path should equal the remainder
      else
        throw err

    req.remainder = inodePath.remainder    # path contains un-matching remaining elements
    req.data = content inodePath.path, parse: false
    req.filename = inodePath.path          # TODO: consider a scoped or different name?

    log.debug 'files return', {path: inodePath.stat, remainder: req.remainder, data: req.data}

router = ->
  r = new express.Router()
  treeRouter = new TreeRouter root
  r.use treeRouter.process.bind treeRouter
  r






router.TreeRouter = TreeRouter
router.root = root
router.get = get

module.exports = router
