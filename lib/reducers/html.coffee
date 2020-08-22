marked = require 'marked'

html = (opts)->
  input = ''
  [
    ''
    (acc, value)->
      input = input + '\n\n' + value
    (v)-> marked v
  ]

module.exports = html
