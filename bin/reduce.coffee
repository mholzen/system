{Arguments} = require '../lib/mappers/args'
transformers = require '../streams/transformers'
reducers = require '../lib/reducers'
{stream} = require '../lib'
{parse, map} = transformers
outputter = require '../lib/outputter'

module.exports = ->
  # TODO: lift common code in bin/{map,reduce,filter}.coffee
  [memo,reducer,output] = []
  try
    args = process.argv[2..]
    args = Arguments.from(args).all()
    reducer = reducers args...
  catch e
    console.error e.message + e.stack
    console.error "help: " + reducers.signature?.helper()
    process.exit 1

  if typeof reducer == 'undefined'
    console.error "cannot get reducer from '#{args}'"
    console.error "help: " + reducers.signature?.helper()
    log.logStream.close()
    process.exit 2

  if typeof reducer != 'function'
    console.error "got a typeof '#{typeof reducer}' instead of a function from '#{args}'"
    console.error "help: " + reducers.signature?.helper()
    process.exit 3

  # [memo, reducer, output] = reducer()

  stream process.stdin
  .through parse()
  .reduce null, reducer
  .errors (err)->
    console.log err
    process.exit 1
    # TODO: any errors in outputter will not set the process exit code
  .through outputter process.stdout, process.stderr



# #!/usr/bin/env coffee
# h = require 'highland'
# log = require '@vonholzen/log'
# {parse} = require '../lib'
# Promise = require 'bluebird'
# isPromise = require 'is-promise'
# {reducers} = require '../lib'
# commandLineArgs = require 'command-line-args'

# options = commandLineArgs [
#   {name: 'terms', type: String, multiple: true, defaultOption: true},
#   {name: 'duration', alias: 'd', type: Number}
# ]

# reducersByName =
#   'Available reducers:\n  ' + Object.keys(reducers).join('\n  ')+ '\n'

# name = options.terms?[0]
# if not name?
#   process.stdout.write reducersByName
#   process.exit()

# reducerOptions = options.terms[1..]


# reducer = reducers[name]
# if not reducer?
#   process.stderr.write 'Error: cannot find reducer ' + name
#   process.stderr.write reducersByName
#   process.exit(1)

# [memo,reducer,output] = reducer reducerOptions

# parser = new parse.Parser()

# reduce = h.pipeline(
#   h.stopOnError (err)->console.log err
#   h.split()
#   h.filter (line) -> line.length > 0
#   h.map (item)-> parser.parse item
#   # h.map parse
#   h.reduce memo, reducer
#   h.apply (memo)->
#     if typeof output == 'function'
#       memo = output memo
#     if typeof memo == 'object'
#       if typeof memo?.toJSON == 'function'
#         memo = memo.toJSON()
#       if memo instanceof Set
#         memo = memo.values()
#       memo = JSON.stringify memo
#     process.stdout.write memo + '\n'
# )

# process.stdin.pipe reduce

# if options.duration?
#   setTimeout ->
#     log 'reduce unpipe'
#     process.stdin.unpipe(reduce)
#     reduce.end()
#     # when piping to reduce from another app, the source app will not exit unless it tries to write to the close pipe, at which point it fails/exits
#     process.exit(0)
#   , options.duration
