#!/usr/bin/env coffee

mappers = require '../lib/mappers'
{Arguments} = mappers.args

{stream} = require '../lib/'
{parse, map} = require '../streams/transformers'
outputter = require '../lib/outputter'

searchers = require '../lib/searchers'

module.exports = ->
  # TODO: generalize
  # options.root = searchers()
  # if name == 'tableString'
  #   options.width = process.stdout.columns

  try
    args = process.argv[2..]
    args = Arguments.from(args).all()
    mapper = mappers args...


  catch e
    console.error e.message
    console.error "help: " + mappers.signature?.helper()
    process.exit 1

  if not mapper?
    console.error "cannot get mapper from '#{args}'"
    console.error "help: " + mappers.signature?.helper()
    process.exit 2

  stream process.stdin
  .through parse()
  .through map mapper
  .errors (err)->
    console.log err
    process.exit 1
    # TODO: any errors in outputter will not set the process exit code
  .through outputter process.stdout, process.stderr
