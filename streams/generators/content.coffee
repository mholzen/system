content = require '../../lib/mappers/content'
stream = require '../../lib/stream'

module.exports = (data, options)->
  stream content data, options