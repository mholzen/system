_ = require 'lodash'
path = require './path'
{NotFound, NotProvided, NotMapped} = require '../errors'
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


getResolveFn = (data)->
  if typeof data?.resolve == 'function'
    return data.resolve

  root = getRoot data
  if root?
    return (data)->
      r = path data, root

      if not r.to?
        # log.debug {root}
        throw new NotFound data, root
      
      if r.remainder().length > 0
        throw new Error "not specific enough (#{data})" 

      if typeof r.to == 'function'
        return r.to

      if typeof r.to.create == 'function'
        return r.to


      throw new NotMapped data, 'function '

  throw new NotMapped data, 'resolveFn'


module.exports = (data, options)->
  # log.here {data, options}

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

    # r = _.get options.req.root, data
    # r = path(data).follow(options?.req?.root)
    # if not r?
    #   throw new NotFound data, options.req.root

    r = resolveFn data, options
    if typeof r == 'function'
      return r
      # args = options?.req?.args?.all()    # TODO: weird
      # if not args?

      # # log 'function.exit', {args}
      # return (data)-> r data, args...
      
    if typeof r?.create == 'function'
      return r.create options

    if typeof r == 'object'
      # we found an object, but we need more info
      throw new NotFound data, Object.keys r

  throw new NotMapped data, 'function'
  