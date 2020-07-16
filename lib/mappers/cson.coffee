CSON = require 'cson'
{defaultReplacer} = require './json'

module.exports = (data, options)->
  replacer = options?.replacer ? defaultReplacer
  if data instanceof Buffer
    data = data.toString()
  if typeof options?.res?.type == 'function'
    options?.res?.type 'application/json'
  CSON.stringify data, replacer, options?.space
