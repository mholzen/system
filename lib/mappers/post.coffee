request = require './request'

module.exports = (data, options)->
  r = request data
  r.method = 'POST'
  r.payload = options.payload
  await r.send()
