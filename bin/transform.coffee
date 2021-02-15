{Arguments} = require '../lib/mappers/args'
transformers = require '../streams/transformers'
{stream} = require '../lib'
{parse, map} = transformers
outputter = require '../lib/outputter'

module.exports = ->
  try
    args = process.argv[2..]
    args = Arguments.from(args).all()
    transformer = transformers args...
  catch e
    console.error e.message
    console.error "help: " + transformers.signature?.helper()
    process.exit 1

  if not transformer?
    console.error "cannot get transformer from '#{args}'"
    console.error "transformers:\n" + transformers()
    process.exit 2

  stream process.stdin
  .through parse()
  .through transformer
  .errors (err)->
    console.log err
    process.exit 1
    # TODO: any errors in outputter will not set the process exit code
  .through outputter process.stdout, process.stderr
