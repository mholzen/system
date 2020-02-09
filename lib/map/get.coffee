_ = require 'lodash'
log = require '../log'
{toArray} = require './args'

getter = (paths, options)->
  # fields = toArray options
  # if fields?.length != 1
  #   throw new Error 'expecting exactly one argument'
  # (data)->_.get data, fields[0], def
  (data)->_.get data, paths, options?.default

get = (data, paths, options)->(getter paths, options) data

get.getter = getter

module.exports = get