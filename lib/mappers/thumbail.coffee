log = require '../log'
name = require './name'

module.exports = (data)->
  if data instanceof Array
    # need to know the context?
    return

  if typeof data == 'string'
    # assume html - add css that makes images smol
    return ''