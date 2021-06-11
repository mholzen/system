stream = require '../lib/stream'
{NotProvided, NotFound} = require '../lib/errors'
{isStream} = stream
{Arguments} = require '../lib/mappers/args'
json = require '../lib/mappers/json'
isPromise = require 'is-promise'
# root = require './root'

getFunc = require './handlers/getFunc'

#TODO: consider whether Pipe should use stream to implement

find = (key, data, root) =>
  if (typeof data == 'object') and (data.hasOwnProperty key)
    # DEBUG: when key=mappers, it returns the mappers creator function
    # option 1: creator functions are handled differently
    # log.debug 'found key in data', {key}
    return data[key]
  if root? and key of root
    # log.debug 'found key in root', {key}
    return root[key]
  throw new NotFound key, data, root

class Pipe
  constructor: (pipe, root)->
    if not pipe instanceof Array
      throw new Error 'needs Array'

    @pipe = pipe
    @root = root

  process: (req, res, next)->
    req.root = @root    # TODO: necessary? to:simplify
    req.data = @root

    try
      await @processPath req, res, next
      if req.data? and (not res.headersSent)
        await @respond req, res
    catch err
      # log.debug 'process.error', {path: req.path, err: err.stack}
      if err.send?
        err.send res
      else
        res.status 500
        .type 'text/plain'
        .send err.stack

    if not req.data?
      res.status 404
      .send 'req.data is not defined'
      return

    next()

  func: (req, res)->
    getFunc req, res
    segment = req.remainder.shift()

    log.debug 'Pipe.processPath', {segment, remainder: req.remainder, data: req.data}
    if not segment?
      # log.error 'empty segment'
      return

    if segment instanceof Array
      p = new Pipe segment, @root
      try
        p.processPath req, res, next
      catch err
        log.error 'pipe.processPath.pipe', {pipe: @pipe, first, err}
      return

    if typeof segment == 'string'   
      args = Arguments.from segment
      first = args.first()

      target = find first, req.data, @root

    if typeof target == 'function'
      log.debug 'calling handler', {name: first}
      # DEBUG: when req.data=/mappers, target calls the mappers() function here
      if target.constructor.name == 'AsyncFunction'
        throw new Error 'async function'
      try
        target req, res
        return
      catch err
        log.error 'pipe.processPath.string', {pipe: @pipe, first, err: err.stack}
        req.error = err
        throw err


  processPath: (req, res, next)->
    req.remainder = Array.from @pipe

    # log.debug 'processPath.start', {}
    while req.remainder?.length > 0
      segment = req.remainder.shift()
    
      log.debug 'Pipe.processPath', {segment, remainder: req.remainder, data: req.data}
      if not segment?
        # log.error 'empty segment'
        continue

      if segment instanceof Array
        p = new Pipe segment, @root
        try
          p.processPath req, res, next
        catch err
          log.error 'pipe.processPath.pipe', {pipe: @pipe, first, err}
        continue

      if typeof segment == 'string'   
        args = Arguments.from segment
        first = args.first()

        target = find first, req.data, @root

      if typeof target == 'function'
        log.debug 'calling handler', {name: first}

        # if target.constructor.name == 'AsyncFunction'
        #   throw new Error 'async function'
        try
          target req, res, @root
          continue
        catch err
          log.error 'pipe.processPath.string', {pipe: @pipe, first, err: err.stack}
          req.error = err
          throw err
          break

      req.data = target

      # continue
      # throw new Error "unknown '#{typeof segment}' segment '#{segment}'"

    req.data

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
        req.data = json req.data
        res.type 'application/json'

    if typeof req.data == 'string'
      return res.send req.data

    if not isStream req.data
      req.data = Object.keys req.data

    # log.debug {data: req.data}
    data = await reducers.reduce req.data.map(id), 'html'
    .toPromise Promise

    res.send data

  mapper: (req, res)->
    (data)->
      req.data = data
      @processPath req, res
      req.data

module.exports = Pipe
