log = require '../log'
pug = require 'pug'

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

toTemplate = (data, options)->
  # if typeof data == 'function'
  #   return data

  # if data?.content instanceof Buffer
  #   data.content = data.content.toString()

  # if typeof data == 'string'
  #   data =
  #     content: data

  # if typeof data?.content == 'string'
  pugOptions = {}
  if data?.path?
    pugOptions.filename = data.path
  return pug.compile string(content(data)), pugOptions

  # throw new Error "cannot make template from #{typeof data}:'#{log.print data}'"
    
# HAVE MADE THIS ASYNC by reading the content
mapper = (data, options)->
  if options?.template?
    templateFn = toTemplate options?.template, options
  else
    templateFn = pug.compile data, options

  if typeof templateFn != 'function'
    throw new Error "cannot get template function"

  res = templateFn data

  # TODO: function with side effects?
  if typeof options?.res?.type == 'function'
    options?.res?.type 'text/html'
  
  res

mapper.post = (resource, data, options)->
  mapper[resource] = toTemplate data, options

mapper.create = (options)->
  toTemplate options?.template

module.exports = mapper