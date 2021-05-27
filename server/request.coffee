{request} = require '../lib/mappers'
module.exports = (data)->
  if data instanceof Array
    data = data.join '/'

  data = 'http://127.0.0.1:3001/' + data      # TODO: understand why localhost instead of 127.0.0.1 throws
  request data