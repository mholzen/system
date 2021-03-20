{fileContentSync} = require '../content'
{Template} = require '../template'
{Template} = require '../template'

map = (memo, value)->
  log {d:Object.entries(value)}

  Array.from(Object.entries(value)).reduce (memo, entry)->
    memo ?= {}
    memo[entry[0]] = entry[1]
    memo
  , {}

graph = new Template fileContentSync( __dirname+'/graph.html').toString()
graph2 = new Template fileContentSync( __dirname+'/graph2.html').toString()

# TODO: should be async
module.exports =
  # graph: new Template fileContentSync( __dirname+'/graph.html').toString()
  # graph2: new Template fileContentSync( __dirname+'/graph2.html').toString()

  graph: (x)-> graph.substitute x
  graph2: (x)-> graph2.substitute x

reference = (data)->
  log 'reference', {data}
  if typeof data == 'object'
    return Object.keys(data).map (key)-> module.exports.reference key
    .reduce map

  if typeof data == 'string'
    r = {}
    for k, v of module.exports
      log 'inspecting', {k,v}
      t = v?.template?.substitutions?.some (s)->
        log {s, data, t: s.includes data}
        s.includes data
      if t
        r[k] = v
    return r

  throw new Error "cannot get references from #{data}"

module.exports.graph.template = graph
module.exports.graph2.template = graph2

module.exports = Object.assign module.exports, {reference}