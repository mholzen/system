_ = require 'lodash'
log = require '../log'
{toArray} = require './args'

getter = (path, options)->
  if not path?
    throw new Error 'no path to get'
  (data)->
    if data instanceof Map
      data = Array.from data
    _.get data, path, options?.default

get = (data, path, options)->(getter path, options) data

get.getter = getter

module.exports = get