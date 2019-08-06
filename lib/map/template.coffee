log = require '../log'
query = require '../query'
args = require './args'

class Template
  constructor: (template)->
    @template = template ? ''
    @expression = /#{(.*?)}/g

  expressions: ->
    @template.match @expression

  substitute: (data)->
    result = @template

    if not (data instanceof Array)
      data = [ data ]
    for d in data
      for key, value of d
        result = result.replace '#{'+key+'}', value
    result

template = (options)->
  if options instanceof Array
    if typeof options?[0] == 'string'
      options =
        template: options[0]
  if typeof options == 'string'
    options =
      template: options

  pattern = options.template ? ''

  (data)->
    result = pattern
    for key, value of data
      result = result.replace '#{'+key+'}', value
    result

template.Template = Template

template.substitute = (substitutions...)->
  substitutions = args() substitutions

  (data)->
    matches = query('template').match data
    if not matches?
      return

    t = new Template matches[0].value.template
    t.substitute substitutions

module.exports = template
