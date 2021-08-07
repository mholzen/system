{stream} = require '../../lib/mappers'
transformers = require '../../streams/transformers'
augmentArgsMapper = require './augmentArgsMapper'

transform = (req, res)->
  if not stream.isStream req.data
    req.data = stream req.data

  if not stream.isStream req.data
    throw new Error "need a stream"

  augmentArgsMapper req, res
  func = req.mapper
  args = req.args

  if not func?
    return res.type('text/plain').status(404).send "function '#{name}' not found"

  if typeof func != 'function'
    req.data = func
    return

  req.data = req.data.through (s)->
    # Object.assign req.args.options, {req,res}
    # log 'transform.through', {args: req.args}
    a = req.args.all()
    # log 'transform.through', {a}
    func s, a...

module.exports = transform
