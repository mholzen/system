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

  log.debug 'returning', {resource, context, first}
 
  return resource


class TreeRouter
  constructor: (root)->
    if not root?
      throw new Error 'missing root data'
    @root = root
    log.debug {root}
    @regexp = new RegExp '/*([^/]*)(.*)'

  process: (req, res, next)->
    req.data = @root
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

    if typeof req.data == 'function'
      data = req.data.apply()
      if stream.isStream data
        return res.send await data.collect().toPromise Promise

      return res.send data
      # return res.type('text/plain').send 'function with properties: ' + Object.getOwnPropertyNames(req.data).join(',')

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

    log.debug 'processPath', {path: req.path, remainder: req.remainder}
    while req.remainder?.length > 0

      log.debug 'router.process', {remainder: req.remainder, req_data: req.data}

      first = req.remainder.shift()
      if not first?
        log.debug 'empty first'
        return res.status(404).send('empty first path element')

      if not (first?.length > 0)
        log.debug 'no more paths. about to send response', {first, remainder: req.remainder}
        break

      target = =>
        if (typeof req.data == 'object') and (first of req.data)
          return req.data[first]
        if (first of @root)
          return @root[first]
        # return res.status(404).send "cannot find #{first} in #{req.data} nor root"

      target = target()
      if not target
        return res.status(400).send("cannot lookup '#{first}' in req.data of type #{typeof req.data} nor in root")


      if typeof target == 'function'
        log.debug 'calling handler', {name: first}
        await target req, res, @
        continue

      if typeof target != 'object'
        return res.status(500).send "lookup in non-object"

      req.data = target

rootInode = inodes()

types =
  'css': 'text/css'
  'jpg': 'image/jpeg'
  'html': 'text/html'

root =
  generators: generators
  searchers: (req, res, router)->
    name = req.remainder.shift()
    req.data = searchers()
    if not name?  
      return
    if not name in req.data
      return res.status(404).send "'#{name}' not found in #{req.data}"
    req.data = req.data[name]
    
  type: (req, res, router)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      return res.status(200).send Object.keys(types).sort()

    if not (type = types[name])
      return res.status(404).send "'#{name}' not found"

    # get data
    req.data = router.root
    await router.processPath req, res

    if not req.data?
      return res.status(400).send 'no data'

    res.type type


  literals: (req, res)->
    if not (req.remainder?.length > 0)
      throw new Error "no items in req.remainder"

    req.data = req.remainder.shift()
    # log.debug 'literals handler', {data: req.data, remainder: req.remainder}

  mappers: (req, res, router)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      req.data = Object.keys(mappers).sort()
      return

    if not (mapper = mappers[name])
      return res.status(404).send "'#{name}' not found"

    # process req.remainder as if it were root
    req.data = router.root
    await router.processPath req, res

    if not req.data?
      return res.status(400).send 'no data'

    # perhaps mapper can handle that?
    if isPromise req.data
      req.data = await req.data

    req.data = mappers[name] req.data
    req.remainder = ''

  map: (req, res, router)->
    name = req.remainder.shift()
    if not (name?.length > 0)
      req.data = Object.keys(mappers).sort()
      return

    if not (mapper = mappers[name])
      return res.status(404).send "'#{name}' not found"

    if not req.data?
      return res.status(400).send 'no data'

    # perhaps mapper can handle that?
    if isPromise req.data
      req.data = await req.data

    if req.data instanceof Buffer
      req.data = req.data.toString()

    req.data = mapper req.data

  reducers: reducers


  files: (req, res) ->
    path = req.remainder ? []
    stat = await rootInode.get path
    req.remainder = path    # path contains un-matching remaining elements

    req.data = content stat.path, parse: false

    # log.debug 'files return', {path: stat.path, remainder: req.remainder, data: req.data}

router = ->
  r = new express.Router()
  treeRouter = new TreeRouter root
  r.use treeRouter.process.bind treeRouter
  r

router.TreeRouter = TreeRouter
router.root = root
router.get = get

module.exports = router
