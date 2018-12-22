log = require '@vonholzen/log'
_ = require 'lodash'

content = require './content'
html = require './html'
summarize = require './summarize'
table = require './table'
text = require './text'
url = require './url'
image = require './image'
path = require 'path'
graph = require './graph'
parse = require './parse'
request = require './request'

mappers =
  augment: (opts)->
    opts.name = opts.name ? opts[0]
    if typeof opts.name != 'string'
      throw new Error 'cannot find name for augment'

    if typeof opts.mapper != 'function'
      opts.mapper = mappers[opts.name]()
      if not opts.mapper
        throw new Error "cannot find '#{opts.name}' in '#{Object.keys(mappers)}'"
    opts.addSource = opts.addSource ? true

    if opts.addSource
      source = mappers.source()

    (value)->
      if typeof value != 'object'
        value =
          value: value
        # throw new Error 'cannot agument a non-object type'

      output = await opts.mapper(value)

      log 'augment', {type: typeof output, value, output}
      value[opts.name] = output

      if opts.addSource
        if not value?.source?
          value.source = source(value)
        value.source = "/map/#{opts.name}#{value.source}"

      value

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

  basename: ->
    (value)->
      if value?.path
        path.basename value?.path

  content: -> content

  dirname: ->
    (value)->
      if value?.path
        path.dirname value?.path

  graph: (opts)->
    [memo,reducer] = graph(opts)
    (value)->
      if typeof value == 'object'
        if value.nodes? and value.edges?
          return value
        if value?.type == 'file'
          readable = await content value
          return parse(readable).reduce(reducer, memo)

  image: image

  html: html

  json: (opts)->
    (value)->
      result = {}
      result[opts] = value
      JSON.stringify result

  location: ->
    (value)->
      if typeof value == 'string'
        return value
      if value?.path?
        return value.path
      if value?.url?
        return value.url

  markdown: ->
    (value)->
      if typeof value == 'string'
        value = value.replace /\siframe:([^\s]+)\s/g, '<iframe frameBorder="0" src="$1"></iframe>'
        value = value.replace /(?:\s)thumb:([^\s]+)/g, ' <a r=1 href="$1"><img src="$1"></a>'
      value

  name: ->
    (value)->
      if value?.name?
        value = value.name
      if value?.path?
        value = path.basename value?.path
      return if typeof value == 'string'
        value?.replace /\.[^/.]+$/, ''
      else
        value

  path: ->
    mappers.pick 'path'

  pick: (fields)->
    (value)->
      log 'pick', {fields, value}
      if fields instanceof Array
        _.pick value, fields
      else
        value[fields]

  request: -> request

  response: -> request

  post: (opts)->
    (resource)->
      r = request(resource)
      r.method = 'POST'
      r.payload = opts.payload
      await r.send()

  source: ->
    (value)->
      if value?.source?
        return value.source
      if value?.url?
        return value.url
      if value?.path?
        return "/files#{value.path}"

  string: ->
    (value)->
      if typeof value == 'object'
        if typeof value?.toJSON == 'function'
          value = value.toJSON()
        if value instanceof Set
          value = value.values()
        value = JSON.stringify value

  sum: (opts)->
    opts = opts ? []
    total = opts.initial ? 0
    (x)->
      if (typeof x == 'object')
        x = x.value
      if (n = _.toNumber x) != NaN
        x = n
      log 'sum', {x, total}
      total = total + x

  summarize: summarize

  timestamp: ->
    (value)-> Date.now()

  table: table.map
  tableString: table.mapString
  text: -> text
  url: -> url

module.exports = mappers
