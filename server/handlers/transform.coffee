{stream} = require '../../lib/mappers'
transformers = require '../../streams/transformers'
{Arguments} = require '../../lib/mappers/args'
augmentArgsMapper = require './augmentArgsMapper'

{log} = require '../../lib'
Path = require 'path'

# getName = (remainder)->   # async
#   part = remainder.shift()
#   [name, words...] = part.split ','

#   if not (name?.length > 0)
#     return []
#     # throw new Error "no name provided"    # TODO: this exception is not shown to the user
#     # req.data =
#     #   req_data: req.data
#     #   'property': Object.getOwnPropertyNames data
#     #   'req.data.functions': functions data
#     #   'mappers': Object.keys mappers
#     # return

#   options = args words
#   # options = resolveNameOption options, 'template'

#   # if any options require an filesystem, resolve these now
#   # options = await resolvePathOption options, 'template', req

#   return [name, options]

transform = (req, res)->
  if not stream.isStream req.data
    req.data = stream req.data

  if not stream.isStream req.data
    throw new Error "need a stream"

  augmentArgsMapper req, res
  func = req.mapper
  args = req.args

  # segment = req.remainder.shift()
  # args = Arguments.from segment
  # name = args.first()
  # # [name, options] = await getName req.remainder

  # # add request and response to the context for this handler
  # # options = options ? {}
  # # options.req = req
  # # options.res = res
  # Object.assign args.options, {req, res, resolve: transformers}

  # a = args.all()
  # f = transformers a...
  if not func?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof func != 'function'
    req.data = func
    return

  req.data = req.data.through (s)->
    Object.assign req.args.options, {req,res}
    log 'transform.through', {args: req.args}
    a = req.args.all()
    log 'transform.through', {a}
    func s, a...

module.exports = transform
