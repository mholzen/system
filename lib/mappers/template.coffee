log = require '../log'
query = require '../query'
args = require './args'
parse = require './parse'
isPlural = require './isPlural'

es6 =
  compile: require 'es6-template-strings/compile'
  resolve: require 'es6-template-strings/resolve-to-string'
pug = require 'pug'


defaultTemplate = (data)->
  if (data?.req?.params?.base.slice(-1) == '/') and (isPlural data?.req?.params?.base.slice(0,-1))
    # look for file based on the basename
    throw new Error 'must make this function async'

class Es6Template
  constructor: (template)->
    @template = template
    @compiled = es6.compile @template
    @substitutions = @compiled.substitutions

  substitute: (data)->
    es6.resolve @compiled, data

class PugTemplate
  constructor: (template)->
    @template = template
    @compiledFunction = pug.compile @template

  substitute: (data)->
    @compiledFunction data

createTemplate = (options)->
  template = options?.template ? options
  if not template?
    if not (template = defaultTemplate options)?
      throw new Error "don't know how to create a template without one"

  content = template.content ? template
  if not content?
    throw new Error "don't know how to create a template without content"

  t = if template.path?.endsWith '.pug'
    new PugTemplate content
  else
    new Es6Template content

  f = (data)->
    if data instanceof Buffer
      data = parse data

    if data instanceof Array
      data = {array: data}

    t.substitute data
  f.template = t
  return f

template = (data, options)->
  t = createTemplate options
  return t Object.assign {}, data, options
template.create = createTemplate

module.exports = template