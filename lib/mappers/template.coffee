log = require '../log'
query = require '../query'
args = require './args'
es6template = require 'es6-template-strings'

class Template
  constructor: (template)->
    @template = template?.content ? template ? ''

  substitute: (data)->
    return es6template @template, data

template = (data, options)->
  if typeof options?.res?.type == 'function'
    options.res.type 'text/html'

  t = new Template options?.template
  t.substitute data

template.create = (options)->
  t = new Template options?.template
  (data)-> t.substitute data

template.Template = Template

template.substitute = (substitutions...)->
  substitutions = args substitutions

  (data)->
    matches = query('template').match data
    if not matches?
      return

    t = new Template matches[0].value.template
    t.substitute substitutions

module.exports = template
