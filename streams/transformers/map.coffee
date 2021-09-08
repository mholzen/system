stream = require '../../lib/stream'
isStream = require '../../lib/mappers/isStream'
resolve = require '../../lib/resolve'

module.exports = (mapper, options)->
  (inputStream)->
    inputStream
    .map mapper
