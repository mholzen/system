{args} = require '../lib/mappers'
transformers = require '../streams/transformers'
{stream} = require '../lib'
{parse, map} = transformers
outputter = require '../lib/outputter'

noName = ->
  try
    transformers()
  catch e
    console.error "no name provided"
    console.error transformers.signature?.helper()
    process.exit 1


module.exports = ->
  name = process.argv[2]
  if not name?
    transformer = noName()

  options = args process.argv[3..]
  # options.root = searchers()
  options.flat = true

  try
    transformer = transformers name, options
  catch e
    console.error "Name'#{name}' not found"
    console.log "Available transformers:\n" + e.set
    process.exit 1

  if not transformer?
    console.error "cannot find '#{name}'"
    console.log "transformers:\n" + transformers()
    process.exit 1

  stream process.stdin
  .through parse()
  .through map mapper, options
  .errors (err)->
    console.log err
    process.exit 1
    # TODO: any errors in outputter will not set the process exit code
  .through outputter process.stdout, process.stderr
