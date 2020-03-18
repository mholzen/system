express = require 'express'
log = require '@vonholzen/log'
_ = require 'lodash'
isPromise = require 'is-promise'

{stream, mappers, searchers, reducers, generators, inodes} = require '../lib'
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

  return resource


class TreeRouter
  constructor: (root)->
    if not root?
      throw new Error 'missing root data'
    @root = root
    @regexp = new RegExp '/*([^/]*)(.*)'

  process: (req, res, next)->
    try
      await @processPath req, res, next
      if req.data?
        await @respond req, res
    catch err
      res.status(500).send err.toString()
    next()

  respond: (req, res)->
    if not req.data?
      res.status 404
      req.data = @root

    req.data = await req.data
    log.debug 'respond', {data: 'typeof-' + typeof req.data}
    if typeof req.data == 'number'
      req.data = req.data.toString()

    if req.data instanceof Buffer
      return res.send req.data

    if typeof req.data == 'object'
      if req.data instanceof Buffer
        # streamable?
        return res.send(req.data.toString())

      if not stream.isStream req.data
        # req.data = JSON.stringify req.data
        req.data = mappers.json req.data
        res.type 'application/json'

    if typeof req.data == 'string'
      return res.send req.data

    if not stream.isStream req.data
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

    # req.data = req.data ? @root

    log.debug 'processPath', {path: req.path, remainder: req.remainder}
    while req.remainder?.length > 0

      # matches = req.remainder.match @regexp

      log.debug 'router.process', {remainder: req.remainder, req_data: req.data}

      # if not matches? or not matches[1]?
      #   log.debug 'unknown first'
      #   return res.status(404).send('cannot determine first path element')

      # [, first, remainder] = matches
      first = req.remainder.shift()
      if not first?
        log.debug 'empty first'
        return res.status(404).send('empty first path element')

      if not (first?.length > 0)
        log.debug 'no more paths. about to send response', {first, remainder: req.remainder}
        break

      # if typeof req.data != 'object'
      #   return res.status(400).send("cannot lookup '#{first}' in req.data of type #{typeof req.data}")

      log.debug 'router handler get', {name: first}
      handler = await get req.data, first, @root

      if not handler?
        return res.status(404).send("cannot find '#{first}' in #{log.print req.data}")

      # req.remainder = remainder

      if ['object', 'number', 'string'].includes typeof handler
        req.data = handler
        continue

      if typeof handler != 'function'
        return res.status(500).send("unsupported handler type #{typeof handler}")

      await handler req, res, @

rootInode = inodes()

types =
  'css': 'text/css'
  'jpg': 'image/jpeg'

root =
  generators: generators
  searchers: searchers

  type: (req, res)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      return res.status(200).send Object.keys(types).sort()

    if not (type = types[name])
      return res.status(404).send "'#{name}' not found"

    res.type type
    # req.data = req.data.toString()

  literals: (req, res)->
    if not (req.remainder?.length > 0)
      throw new Error "no items in req.remainder"

    req.data = req.remainder.shift()
    req.remainder = []
    log.debug 'literals handler', {data: req.data, remainder: req.remainder}

  mappers: (req, res, router)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      return res.status(200).send Object.keys(mappers).sort()

    if not (mapper = mappers[name])
      return res.status(404).send "'#{name}' not found"

    # process req.remainder as if it were root
    await router.processPath req, res

    if not req.data?
      return res.status(400).send 'no data'

    # perhaps mapper can handle that?
    if isPromise req.data
      req.data = await req.data

    if req.data instanceof Buffer
      req.data = req.data.toString()

    req.data = mappers[name] req.data
    req.remainder = ''

  reducers: reducers
  files: (req, res) ->
    path = req.remainder ? []
    log.debug {rootInode}
    stat = await rootInode.get path
    req.remainder = path.join sep

    req.data = content stat.path, parse: false

    log.debug 'fileHandler', {path: stat.path, remainder: req.remainder, data: req.data}
    await req.data

router = ->
  r = new express.Router()
  treeRouter = new TreeRouter root
  r.use treeRouter.process.bind treeRouter
  r

router.TreeRouter = TreeRouter
router.root = root
router.get = get

module.exports = router
