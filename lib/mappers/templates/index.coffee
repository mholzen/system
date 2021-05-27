{fileContentSync} = require '../content'
{create} = require '../template'

map = (memo, value)->
  log {d:Object.entries(value)}

  Array.from(Object.entries(value)).reduce (memo, entry)->
    memo ?= {}
    memo[entry[0]] = entry[1]
    memo
  , {}

# TODO: should be async
templates =
  graph: create fileContentSync( __dirname+'/graph.html').toString()
  graph2: create fileContentSync( __dirname+'/graph2.html').toString()
  scale: create fileContentSync( __dirname+'/scale.html').toString()
  vue: create fileContentSync( __dirname+'/vue.html').toString()
  slideshow: create fileContentSync( __dirname+'/slideshow.html').toString()

reference = (data)->
  log 'reference', {data}
  if typeof data == 'object'
    return Object.keys(data).map (key)-> module.exports.reference key
    .reduce map

  if typeof data == 'string'
    r = {}
    for k, v of templates
      # log.debug 'inspecting', {k,v}
      t = v?.template?.substitutions?.some (s)->
        # log.debug {s, data, t: s.includes data}
        s.includes data
      if t
        r[k] = v
    return r

  throw new Error "cannot get references from #{data}"

module.exports = Object.assign templates, {reference}