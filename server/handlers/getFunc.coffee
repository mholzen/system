{NotMapped} = require '../../lib/errors'
mappers = require '../../lib/mappers'
{Arguments} = require '../../lib/mappers/args'

consume = (array)->
  if not array instanceof Array
    throw new TypeError "expecting Array; got #{log.print array}"   # make

  if array.length <= 0
    throw new NotProvided "empty array"

  array.shift()

module.exports = (req, res)->
  func = consume req.remainder

  if typeof func == 'string'
    # TODO: support req.data[name] == function
    # TODO: support objectPaths to: [apply, templates, person, bar]

    args = Arguments.from func
    Object.assign args.options, {req, res}
    a = args.all()
    func = mappers a...                 # TODO: make mappers accept an array of all args

  if func instanceof Array
    pipe = new Pipe func, req.root
    func = pipe.mapper req, res
 
  if typeof func != 'function'
    throw new NotMapped 'func', 'function'
  
  func
