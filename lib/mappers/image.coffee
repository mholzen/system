log = require '../log'
name = require './name'

image = (value)->
  if value instanceof Array
    # need to know the context?
    return

  if typeof value != 'object'
    return

  if (n = name value)?
    return
      image: "/files/data/images/#{log.print n}"
      shape: 'circularImage'

module.exports = image
