{stream} = require '../stream'
{traverse} = require '../traverse'

module.exports = (data, options)->
  stream traverse data, options
