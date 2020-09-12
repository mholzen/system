content = require '../mappers/content'
stream = require '../stream'

module.exports = (data, options)->
  stream content data, options