{args} = require '../lib/mappers'
generators = require '../streams/generators'
{stream} = require '../lib'
{parse, map} = generators
outputter = require '../lib/outputter'

noName = ->
  try
    generators()
  catch e
    console.error "no name provided"
    console.error generators.signature?.helper()
    process.exit 1


module.exports = ->
  name = process.argv[2]
  if not name?
    generator = noName()

  options = args process.argv[3..]
  # options.root = searchers()
  options.flat = true

  try
    generator = generators name, options
  catch e
    console.error "Name'#{name}' not found"
    console.log "Available generators:\n" + e.set
    process.exit 1

  if not generator?
    console.error "cannot find '#{name}'"
    console.log "generators:\n" + generators()
    process.exit 1

  stream process.stdin
  .through parse()
  .toArray (data)->
     generator data, options
  .errors (err)->
    console.log err
    process.exit 1
    # TODO: any errors in outputter will not set the process exit code
  .through outputter process.stdout, process.stderr
