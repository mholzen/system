log = require './log'
requireDir = require 'require-dir'
creator = require './creator'
request = require './mappers/request'
template = require './mappers/template'

# Functions that take one value and return one value
# Can be used in "obj.apply(f)" and "arr.map(f)"

# TODO: some mappers are f=(data, options)
# others are mapper constructors (append)
# Replace them with a create

mappers =
  append: (opts)->
    if typeof opts.value == 'undefined'
      value = opts
      opts =
        value: value

    append = (a,b)->
      # log.debug 'append append', typeof a, b instanceof Array
      return if typeof a == 'string' and typeof b == 'string'
        a + b
      return if b instanceof Array
        b.reduce (memo, value)->
          append memo, value
        , a
      return a

    # log.debug 'append', opts
    (value)->
      c = await content(value)
      return append c, opts.value

  basename: (value)->
    if value?.path
      path.basename value?.path

  dirname: (value)->
    if value?.path
      path.dirname value?.path

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
    r = request resource
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

  # TODO: 
  # tableString: table.tableString

mappers.templates = require './mappers/templates'

mappers = Object.assign mappers, requireDir './mappers'

module.exports = creator mappers