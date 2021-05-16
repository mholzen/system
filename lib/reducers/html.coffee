# this should just reduce the array and convert that to html

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

{create} = require './concat'

module.exports = [
  undefined,
  create(),
  (memo)-> outer memo
]
