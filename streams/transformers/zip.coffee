getFunction = require '../../lib/mappers/function'

module.exports = (inputStream, name, options)->
  log 'zip', {name, options}
  generator = getFunction name, options

  inputStream.zip generator()
