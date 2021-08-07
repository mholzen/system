pug = require 'pug'
string = require  'lib/mappers/string'

class Pug
  constructor: (template)->
    # log 'pugTemplate', {template}
    @template = template
    @compiledFunction = pug.compile @template

  substitute: (data)->
    @compiledFunction data

module.exports = (data)->
  new Pug string data
