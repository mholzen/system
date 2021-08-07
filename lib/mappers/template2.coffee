string = require './string'
content = require './content'
augment = require './augment'
resolve = require './resolve'
{NotMapped} = require '../errors'
getFunction = require './function'

es6 =
  compile: require 'es6-template-strings/compile'
  resolve: require 'es6-template-strings/resolve-to-string'
pug = require 'pug'

class Es6Template
  constructor: (template)->
    # log 'es6template', {template}
    @template = template
    @compiled = es6.compile @template
    @substitutions = @compiled.substitutions

  substitute: (data)->
    es6.resolve @compiled, data

class PugTemplate
  constructor: (template)->
    log 'pugTemplate', {template}
    @template = template
    @compiledFunction = pug.compile @template

  substitute: (data)->
    @compiledFunction data


substitutionsRe =
  pug: /#{(.*)}/g
  es6: /\${(.*)}/g

type = (data)->
  for k, v of substitutionsRe
    matches = data.match v
    if not matches?
      continue
    if matches.length >= 1
      return k

  throw new NotMapped 'type', data

getTemplate = (data, options)->
  data = string data
  t = type data
  switch type data
    when 'pug'
      return new PugTemplate data
    when 'es6'
      return new Es6Template data

  throw new NotMapped data, 'template'

module.exports = getTemplate
