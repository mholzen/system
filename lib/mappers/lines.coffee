{NotMapped} = require '../errors'
content = require './content'

module.exports = (data, options)->
  # TODO: content if filepath
  try
    data = await content data, options
  catch err
    # log.debug 'lines', {stack: err.stack}
    # try something else

  if data instanceof Buffer
    data = data.toString()

  if typeof data == 'string'
    return data.split '\n'
  
  throw new NotMapped data, 'lines'