mappers = require '../../lib/mappers'
isPromise = require 'is-promise'
{Arguments} = require '../../lib/mappers/args'
{isStream} = require '../../lib/stream'
{NotProvided} = require '../../lib/errors'
augmentArgsMapper = require './augmentArgsMapper'

resolveArg = (arg, options)->
  if not (arg instanceof Array)
    return arg

  if arg?[0] != ''
    return arg

  first = arg[1] if arg?[1]?

  if options.req.params.root.handlers[first]?
    return await options.req.params.router.subprocess arg

  return arg

  # throw new Error "can't resolve #{arg} of type '#{typeof arg}"

apply = (req, res)->
  if isStream req.data
    req.data = req.data.collect().toPromise Promise

  data = if isPromise req.data then await req.data else req.data

  req.params.imports = [ req.root.mappers, req.root ]
  augmentArgsMapper req, res
  mapper = req.mapper
  args = req.args

  if not mapper?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof mapper != 'function'
    req.data = mapper
    return

  if args.positional.length > 0
    for p, i in args.positional
      args.positional[i] = await resolveArg p, args.options

  a = args.all()

  # perhaps mapper can handle that?
  if isPromise req.data
    req.data = await req.data

  # log "applying mapper '#{name}' to req.data of type #{typeof req.data}: '#{log.print req.data}'"
  # req.data = mapper.apply req.data, [ req.data ]
  a.unshift req.data
  # log 'apply', {args: a}
  req.data = await mapper.apply @, a

Object.assign apply,
  imports: ['mappers']

module.exports = apply