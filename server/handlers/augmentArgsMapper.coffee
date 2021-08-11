getFunction = require '../../lib/mappers/function'
{NotProvided} = require '../../lib/errors'
{Arguments} = require '../../lib/mappers/args'

module.exports = (req, res)->
  args = req.args
  if not args?
    # because processPath would have had to do that to determine the handler name
    throw new Error "req.args expects to always be defined by #{req.params.segment}"

  name = args.first()
  if not name?
    throw new NotProvided 'name', mappers
  # log 'found function', {name}
  args.positional.shift() # remove name

  Object.assign req.args.options, {req, res}, {imports: req.params.imports}
  req.mapper = getFunction name, req.args.options

  if req.mapper?.type == 'reducer'
    if not (args.positional.length >= 1)
      log.warn "2nd argument missing; (#{args.positional}) for #{name}"