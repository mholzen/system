{request} = require '../lib/mappers'
module.exports = (data)->
  request 'http://localhost:3001/' + data