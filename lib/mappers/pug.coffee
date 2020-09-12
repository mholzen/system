log = require '../log'
pug = require 'pug'
compile = pug.compile

toTemplate = (data, options)->
  if typeof data == 'function'
    return data

  if typeof data == 'string'
    log.debug 'compiling template from', {data}
    return compile data, options

  if typeof data == 'object'
    if data instanceof Buffer
      return compile data.toString(), options

mapper = (data, options)->
  template = toTemplate options?.template
  if not template
    return pug.compile "code " + JSON.stringify data
  template data

mapper.post = (resource, data, options)->
  mapper[resource] = toTemplate data, options

mapper.create = (options)->
  toTemplate options?.template

module.exports = mapper