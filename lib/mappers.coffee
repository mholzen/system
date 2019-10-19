log = require '@vonholzen/log'
_ = require 'lodash'

graph = require './reducers/graph'
parse = require './parse'
path = require 'path'
request = require './request'
stream = require './stream'
table = require './table'
template = require './map/template'

mappers =
  append: (opts)->
    if typeof opts.value == 'undefined'
      value = opts
      opts =
        value: value

    append = (a,b)->
      log 'append append', typeof a, b instanceof Array
      return if typeof a == 'string' and typeof b == 'string'
        a + b
      return if b instanceof Array
        b.reduce (memo, value)->
          append memo, value
        , a
      return a

    log 'append', opts
    (value)->
      c = await content(value)
      return append c, opts.value


  basename: (value)->
    if value?.path
      path.basename value?.path

  dirname: (value)->
    if value?.path
      path.dirname value?.path

  graph: (value, opts)->
    if typeof value == 'object'
      if value.nodes? and value.edges?
        return value
      if value?.type == 'file'
        readable = await content value
        [memo,reducer] = graph opts
        return parse(readable).reduce(reducer, memo)

  location: (value)->
    if typeof value == 'string'
      return value
    if value?.path?
      return value.path
    if value?.url?
      return value.url

  markdown: (value)->
    if typeof value == 'string'
      value = value.replace /\siframe:([^\s]+)\s/g, '<iframe frameBorder="0" src="$1"></iframe>'
      value = value.replace /(?:\s)thumb:([^\s]+)/g, ' <a r=1 href="$1"><img src="$1"></a>'
    value

  request: request

  response: request

  post: (resource, opts)->
    r = request(resource)
    r.method = 'POST'
    r.payload = opts.payload
    await r.send()

  source: (value)->
    if value?.source?
      return value.source
    if value?.url?
      return value.url
    if value?.path?
      return "/files#{value.path}"

  substitute: template.substitute

  timestamp: (value)-> Date.now()

  table: table.map
  tableString: table.mapString

[
  'args'
  'amount'
  'augment'
  'context'
  'content'
  'columns'
  'escape'
  'html'
  'image'
  'json'
  'keys'
  'name'
  'omit'
  'pick'
  'templates'
  'summarize'
  'string'
  'text'
  'template'
  'url'
].forEach (r)->
  mappers[r] = require "./map/#{r}"

module.exports = mappers
