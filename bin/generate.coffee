{args} = require '../lib/mappers'
generators = require '../streams/generators'
{stream} = require '../lib'
{parse, map} = require '../streams/transformers'
outputter = require '../lib/outputter'

module.exports = ->
  name = process.argv[2]
  # if not name?
  #   generator = noName()

  options = args process.argv[3..]
  # options.root = searchers()
  options.flat = true

  try
    generator = generators name, options
  catch e
    console.error e.message
    console.error "help: " + generators.signature?.helper()
    process.exit 1

  if not generator?
    console.error "cannot get generator from '#{name}'"
    console.error "generators:\n" + generators()
    process.exit 2

  stream process.stdin
  .through parse()
  .through generator
  .errors (err)->
    console.log err
    process.exit 1
    # TODO: any errors in outputter will not set the process exit code
  .through outputter process.stdout, process.stderr
