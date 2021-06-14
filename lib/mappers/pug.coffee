{compile}  = require 'pug'

string = (data)->
  if data instanceof Buffer
    return data.toString()
  if typeof data == 'string'
    return data
  throw new Error "cannot make string from #{typeof data}:'#{log.print data}'"

content = (data)->
  if data?.content
    return data.content
  return data

create = (data, options)->
  pugOptions = {}
  if data?.path?
    pugOptions.filename = data.path
  if options?.self?
    pugOptions.self = options.self

  compile string(content(data)), pugOptions
    
pug = (data, options)->
  templateFn = ''
  if options?.template?
    templateFn = create options?.template, options
  else
    options ?= {}
    options.self = true
    if options?.req?.filename?
      options.filename = options?.req?.filename
    # log.debug 'creating template function from data', {data}
    templateFn = compile data, options

  if typeof templateFn != 'function'
    throw new Error "cannot get template function"

  locals = Object.assign {}, data, options
  # log.debug 'applying template function with', {options}
  res = templateFn locals

  # TODO: function with side effects?
  if typeof options?.res?.type == 'function'
    options?.res?.type 'text/html'
  
  res

pug.post = (resource, data, options)->
  pug[resource] = create data, options

pug.create = (options)->
  create options?.template


module.exports = pug