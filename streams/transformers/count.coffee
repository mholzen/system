stream = require '../../lib/stream'

module.exports = (data, options)->

  count = options?.count || 0
  mod = options?.mod
  data.map (x)->
    count += 1
    if mod? and count >= mod
      count = count % mod
    count