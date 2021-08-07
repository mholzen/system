compile = require 'es6-template-strings/compile'
resolve = require 'es6-template-strings/resolve-to-string'

class Es6Template
  constructor: (template)->
    # log 'es6template', {template}
    @template = template
    @compiled = compile @template
    @substitutions = @compiled.substitutions

  substitute: (data)->
    resolve @compiled, data

module.exports = (data)->
  new Es6Template data