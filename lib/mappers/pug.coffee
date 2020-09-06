log = require '../log'
pug = require 'pug'
compile = pug.compile

template = (source, options)->
  if typeof source == 'function'
    return source

  if typeof source == 'string'
    log.debug 'compiling template from', {source}
    return compile source, options

  if typeof source == 'object'
    if source instanceof Buffer
      return compile source.toString(), options

    if source instanceof Array
      throw new Error "cannot create template from array"

    log.debug 'here', {source}

    # now async
    return compile content source

  throw new Error "cannot determine template from #{source}"

mapper = (data, options)->
  source = options?.template
  f = template source
  f data

mapper.post = (resource, data, options)->
  mapper[resource] = template data, options

mapper.create = (options)->
  source = options?.template
  template source

module.exports = mapper