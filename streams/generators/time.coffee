stream = require '../../lib/stream'

module.exports = (data, options)->
  interval = options?.interval || 1000  # ms
  start = Date.now()
  tick = 0

  stream (push, next)->
    f = ->
      tick += 1
      nextTime = start + tick*interval
      now = Date.now()
      timeout = nextTime - now
      setTimeout f, timeout
      push null, new Date now
    f()


