prettyBytes = require 'pretty-bytes'

module.exports = (data, options)->
  if data?.unit == 'bytes'
    return prettyBytes data.value
