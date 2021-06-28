gm = require 'gm'
amount = require './amount'

getSize = (data)->
  try
    return amount data
  catch e
    # ignore
    log.error {e}

  300

module.exports = (data, options)->
  type = options?.res?.get 'Content-Type'
  if type?.startsWith 'image/'

    size = getSize options
    
    gm data
    .resize size, size
    .stream()
