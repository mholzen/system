getFunction = require '../../lib/mappers/function'
{NotProvided} = require '../../lib/errors'
{Arguments} = require '../../lib/mappers/args'

module.exports = (req, res)->
  args = req.args
  if not args?
    # because processPath would have had to do that to determine the handler name
    throw new Error "req.args expects to always be defined by #{req.params.segment}"

  name = args.first()
  if not name?    # TODO: consider requiring /apply,<function> instead of /apply,mappers.<function>  to:consistent
    args = Arguments.from req.remainder.shift()
    name = args.first()

  if not name?
    throw new NotProvided 'name', mappers

  options = Object.assign {}, {req, res}
  Object.assign req.args.options, {req, res}
  args.positional.shift() # remove name
  # log {req_args: req.args, options_req_args: options.req.args}
  req.mapper = getFunction name, options

  if req.mapper?.type == 'reducer'
    if not (args.positional.length >= 1)
      log.warn "2nd argument missing; (#{args.positional}) for #{name}"
      # throw new NotProvided "2nd argument missing; (#{args.positional}) for #{name}"