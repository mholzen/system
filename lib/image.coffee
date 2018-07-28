#!/usr/bin/env coffee

log = require '@vonholzen/log'

image = ->
  (value)->
    if value instanceof Array
      # need to know the context?
      return value

    value.image = "/files/data/images/#{value.name}"
    value.shape = 'circularImage'
    value

module.exports = image
