log = require '../log'

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

module.exports = template
