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

# class Template
#   constructor: (template, options)->
#     if not template?
#       if not (template = defaultTemplate options)?
#         throw new Error "don't know how to create a template without one"

#     @content = template.content ? template
#     if not @content?
#       throw new Error "don't know how to create a template without a content"

#     if template.path?.endsWith '.pug'
#       # throw new Error "don't know how to compile pug template"
#       @compile = pug.compile
#       @resolve = pug.render
#     else
#       @compile = es6.compile
#       @resolve = es6.resolve

#     try
#       log 'compiling', {content: @content}
#       @template = @compile @content
#       @substitutions = @template.substitutions
#     catch e
#       log.error {content: @content}
#       throw e


#   substitute: (data)->
#     if data instanceof Buffer
#       data = parse data

#     if data instanceof Array
#       data = {array: data}

#     # log.debug 'resolving template', {data}
#     return @resolve @template, data

# template = (data, options)->
#   if typeof options?.res?.type == 'function'
#     options.res.type 'text/html'

#   t = new Template options?.template, options
#   t.substitute data

# template.create = (options)->
#   t = new Template options?.template
#   (data)-> t.substitute data

# template.Template = Template

template = (data, options)->
  t = createTemplate options
  return t data
template.create = createTemplate

module.exports = template