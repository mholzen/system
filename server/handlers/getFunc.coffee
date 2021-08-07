{NotFound, NotProvided, NotMapped} = require '../../lib/errors'
mappers = require '../../lib/mappers'
{Arguments} = require '../../lib/mappers/args'

search = (key, data, root) ->
  if (typeof data == 'object') and (data.hasOwnProperty key)
    # DEBUG: when key=mappers, it returns the mappers creator function
    # option 1: creator functions are handled differently
    # log.debug 'found key in data', {key}
    return data[key]
  if root? and key of root
    # log.debug 'found key in root', {key}
    return root[key]

find = (key, data, root) ->
  res = search key, data, root
  if res?
    return res
  throw new NotFound key, data, root

consume = (array)->
  if not array instanceof Array
    throw new TypeError "expecting Array; got #{log.print array}"   # make

  if array.length <= 0
    throw new NotProvided "empty array"

  array.shift()

module.exports = (req, res, root)->
  func = consume req.remainder

  if typeof func == 'string'
    # TODO: support req.data[name] == function
    # TODO: support objectPaths to: [apply, templates, person, bar]

    args = Arguments.from func
    first = args.first()

    target = search first, req.data
    if target?
      if target.constructor.name == 'AsyncFunction'
        throw new Error 'async function'
      return target

    target = search first, root
    if target?
      if typeof target == 'function'
        Object.assign args.options, {req, res}
        a = args.all()
        return (x)->
          target x, a...

      if typeof target.create == 'function'
        Object.assign args.options, {req, res}
        a = args.all()
        return target.create a...
      
      return target   

  if func instanceof Array
    pipe = new Pipe func, req.root
    func = pipe.mapper req, res
 
  if typeof func != 'function'
    throw new NotMapped 'func', 'function'
  
  func
