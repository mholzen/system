_ = require 'lodash'
log = require '../log'
{toArray} = require './args'

getter = (paths, options)->
  if not paths?
    throw new Error 'no path to get'
  (data)->
    if data instanceof Map
      data = Array.from data
    _.get data, paths, options?.default

get = (data, paths, options)->(getter paths, options) data

get.getter = getter

module.exports = get