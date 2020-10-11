marked = require 'marked'

{body, outer} = require '../mappers/html'

html = (options)->
  input = ''
  [
    ''
    (acc, value)->
      input = input + body value, options
    (v)->outer v, options
  ]

module.exports = html
