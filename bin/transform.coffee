{args} = require '../lib/mappers'
transformers = require '../streams/transformers'
{stream} = require '../lib'
{parse, map} = transformers
outputter = require '../lib/outputter'

module.exports = ->
  name = process.argv[2]
  options = args process.argv[3..]

  try
    transformer = transformers name, options
  catch e
    console.error e.message
    console.error "help: " + transformers.signature?.helper()
    process.exit 1

  if not transformer?
    console.error "cannot get transformer from '#{name}'"
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
