log = require '../log'
query = require '../query'
args = require './args'
parse = require './parse'
compile = require 'es6-template-strings/compile'
resolve = require 'es6-template-strings/resolve-to-string'

class Template
  constructor: (template)->
    @template = compile template?.content ? template ? ''
    @substitutions = @template.substitutions

  substitute: (data)->
    if data instanceof Buffer
      data = parse data

    if data instanceof Array
      data = {array: data}

    # log.debug 'resolving template', {data}
    return resolve @template, data

template = (data, options)->
  if typeof options?.res?.type == 'function'
    options.res.type 'text/html'

  t = new Template options?.template
  t.substitute data

template.create = (options)->
  t = new Template options?.template
  (data)-> t.substitute data

template.Template = Template

module.exports = template
