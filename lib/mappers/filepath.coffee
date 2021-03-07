log = require '@vonholzen/log'

filepath = (data)->
  # log.debug 'filepath', data

  if typeof data == 'string'
    if data.startsWith '/'
      return data

  throw new Error "cannot get filepath from '#{data}'"

module.exports = filepath
