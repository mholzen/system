log = require '@vonholzen/log'
marked = require 'marked'

html = (value)->
  if value instanceof Array
    value = value.map((x)->'- ' + x).join '\n'
  if typeof value == 'object'
    value = "<code>#{JSON.stringify value}</code>"

  return '<!DOCTYPE html>
  <html>
  <body>' + marked value
  + '</body>
  </html>'

module.exports = html
