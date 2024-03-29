_ = require 'lodash'
path = require './path'
{NotFound, NotProvided, NotMapped, NotSpecific} = require '../errors'
isStream = require './isStream'

###
Q: is `function` is a reducer because it requires a root?
what are searching functions?
reducer where the memo is the query that gets augment with results from each search set?
###

getRoot = (data)->
  if typeof data?.req?.root == 'object'
    return data.req.root

  if typeof data?.root == 'object'
    return data.root

  # if typeof data == 'object'
  #   return data

  throw new NotMapped data, 'root'

findImports = (data)->
  if typeof data?.req?.imports == 'object'
    return data.req.imports

  if typeof data?.imports == 'object'
    return data.imports

getImports = (data)->
  imports = findImports data
  if imports?
    return imports

  throw new NotMapped data, 'root'

getter = (p)->
  f = (item)->
    try
      return path(p, item)._get()
    catch e
      if not (e instanceof NotFound)
        throw e
  f.description = "get '#{p}'"
  f

find = (array, fn)->    # TODO: need better name than `find` (find returns the value, this returns the result of the function is not falsey)
  if not Array.isArray array
    throw new Error "cannot find in #{log.print array} because it is not an array"

  for i in array
    if v = fn i
      return v
  throw new Error "could not find '#{fn.description}' in '#{log.print array}'"

getResolveFn = (data)->
  if typeof data?.resolve == 'function'
    return data.resolve

  try
    imports = getImports data
    return (d)->
      # imports.find getter d
      find imports, getter d

  catch e
    if not e instanceof NotMapped
      throw e

  root = getRoot data
  if root?
    return (data)->
      r = path data, root

      if not r.to?    # TODO: refactor with path._get
        throw new NotFound data, root

      if r.remainder().length > 0
        throw new Error "not specific enough (#{data})"

      if typeof r.to == 'function'
        return r.to

      if typeof r.to.create == 'function'
        return r.to

      throw new NotSpecific data, 'function', r.to

  throw new NotMapped data, 'resolveFn'


module.exports = (data, options)->
  if typeof data == 'function'
    return data

  if not options?
    throw new NotProvided 'options for resolveFn'
  resolveFn = getResolveFn options

  if data instanceof Array
    data = data.join '.'

  if typeof data == 'string'
    if data.startsWith '/'
      data = data.slice 1
    data = data.replace /\//g, '.'

    r = resolveFn data, options
    if typeof r == 'function'
      return r

    if typeof r?.create == 'function'
      args = options?.req?.args?.positional
      if not args?
        return r.create options
      return r.create args..., options

    if typeof r == 'object'
      # we found an object, but we need more info
      throw new NotFound data, Object.keys r

  throw new NotMapped "#{data} then #{r}", 'function'
