log = require '@vonholzen/log'
marked = require 'marked'

html = (value)->
  if value instanceof Buffer
    # TODO: should not infer jpg as type
    value = '<div class="a"><img src="data:image/jpeg;base64,' + value.toString('base64') + '"></div>'

  if value instanceof Array
    value = value.map((x)->"- [#{x}](./#{encodeURI(x)})").join '\n'
  if typeof value == 'object'
    value = "<code>#{JSON.stringify value}</code>"

  return '<!DOCTYPE html>
  <html>
  <body>' + marked value
  + '</body>
  </html>'

module.exports = html
