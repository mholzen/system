_ = require 'lodash'
{toArray} = require './args'

learnColumn = ->
  # see transformers/get

create = (path, options)->
  if not path?
    throw new Error 'no path to get'

  (data)->
    if data instanceof Map
      data = Array.from data

    if not isNaN (n = parseInt path)
      path = n

    # log.debug 'get', {data, path}
    _.get data, path, options?.default

get = (data, path, options)->(create path, options) data

get.create = create

module.exports = get