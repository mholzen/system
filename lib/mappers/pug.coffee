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
  if options?.self?
    pugOptions.self = options.self
  return compile string(content(data)), pugOptions

  # throw new Error "cannot make template from #{typeof data}:'#{log.print data}'"
    
# HAVE MADE THIS ASYNC by reading the content
pug = (data, options)->
  if options?.template?
    templateFn = create options?.template, options
  else
    options.self = true
    if options?.req?.filename?
      options.filename = options?.req?.filename
    templateFn = compile data, options

  if typeof templateFn != 'function'
    throw new Error "cannot get template function"

  # log.debug 'applying template function with', {data}
  res = templateFn data

  # TODO: function with side effects?
  if typeof options?.res?.type == 'function'
    options?.res?.type 'text/html'
  
  res

pug.post = (resource, data, options)->
  pug[resource] = create data, options

pug.create = (options)->
  create options?.template


module.exports = pug