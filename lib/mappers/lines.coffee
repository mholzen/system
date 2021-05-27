{NotMapped} = require '../errors'
filepath = require './filepath'
content = require './content'

module.exports = (data, options)->
  # TODO: content if filepath
  try
    data = await content data, options
    if data instanceof Buffer
      data = data.toString()
  catch err
    # log.debug 'lines', {stack: err.stack}
    # try something else

  if typeof data == 'string'
    return data.split '\n'
  
  throw new NotMapped data, 'lines'