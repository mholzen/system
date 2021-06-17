concat = require 'concat-stream'

cache = {}

get = (req, res, router)->
  req.base ?= []
  req.base.push 'cache'

  if req.remainder.length == 0
    req.data = ([k, v.data.length, v.type] for k, v of cache)
    return req.data

  key = req.remainder.join '/'
  if key of cache
    hit = cache[key]
    req.data = hit.data
    res.type hit.type
    req.remainder = [] # must indiciate response
    # router.respond req, res
    log.debug 'cache hit', {key, type: hit.type, data: req.data}
    return

  await router.processPath req, res #, next
  value = await req.data

  if res.headersSent
    return # Don't cache if we've already responded (eg. redirect)

  # log.debug 'caching', {key, value}

  if value?._readableState?
    return new Promise (resolve, reject)->
      value.pipe concat (buffer)->
        cache[key] =
          data: buffer
          type: res.get 'content-type'
        req.data = buffer
        resolve req.data

  cache[key] =
    data: req.data
    type: res.get 'content-type'
  
  return req.data

module.exports = {
  cache
  get
}
