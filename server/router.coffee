express = require 'express'
log = require '@vonholzen/log'
_ = require 'lodash'
{stream, mappers, searchers, reducers, generators, content} = require '../lib'
keys = generators.keys

{join, sep} = require 'path'

id = (obj)->
  if typeof obj.path == 'string'
    return obj.path
  obj

streamResponse = (req, res)->
  if not req.data?
    return res.status(404).send('no data')

  log 'router.streamResponse', {data: req.data}
  req.data = await req.data
  if typeof req.data == 'number'
    req.data = req.data.toString()

  if typeof req.data == 'object'
    if not stream.isStream req.data
      req.data = JSON.stringify req.data
      res.type 'application/json'

  if typeof req.data == 'string'
    return res.send req.data

  if not stream.isStream req.data
    req.data = keys req.data

  data = await reducers.reduce req.data.map(id), 'html'
  .toPromise Promise

  log 'router.sending', {data}
  res.send data

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
  constructor: (data)->
    @data = data
    @regexp = new RegExp '/*([^/]*)(.*)'

  process: (req, res, next)->
    req.remainder = req.path
    req.data = @data
    while req.remainder?
      matches = req.remainder.match @regexp

      log 'router.process', {remainder: req.remainder, matches}

      if not matches? or not matches[1]?
        return res.status(404).send('cannot determine first path element')

      [, first, remainder] = matches
      if not first?
        return res.status(404).send('empty first path element')

      if not (first?.length > 0)
        break

      if typeof req.data != 'object'
        return res.status(400).send("cannot lookup '#{first}' in req.data of type #{typeof req.data}")

      handler = await get req.data, first, @data
      if not handler?
        return res.status(404).send("cannot find '#{first}' in #{Object.keys req.data}")

      if ['object', 'number', 'string'].includes typeof handler
        req.data = handler
        req.remainder = remainder
        continue

      if typeof handler != 'function'
        return res.status(500).send("unsupported handler type #{typeof handler}")

      req.remainder = remainder
      log 'router handler', {first, remainder}
      await handler req, res

    await streamResponse req, res
    next()

rootInode = searchers.inodes()

fileHandler = (req, res) ->
  path = req.remainder ? ''
  path = path.split sep
  stat = await rootInode.get(path)
  req.remainder = path.join sep

  if await stat.isDirectory()
    req.data = stat.items
  else
    req.data = content stat.path

  log 'router.files', {path: stat.path, remainder: req.remainder}

  await req.data

root =
  generators: generators
  searchers: searchers
  html: (req, res, next)->
    req.remainder
    mappers.html()
  # mappers: mappers
  # reducers: reducers
  # files: fileHandler

router = ->
  r = new express.Router()
  treeRouter = new TreeRouter root
  r.use treeRouter.process.bind treeRouter
  r

router.TreeRouter = TreeRouter
router.root = root
router.get = get

module.exports = router
