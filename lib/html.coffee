log = require '@vonholzen/log'
marked = require 'marked'

html = (options)->
  (value)->
    if typeof value == 'object'
      value = "<code>#{JSON.stringify value}</code>"

    return '<!DOCTYPE html>
    <html>
    <body>' + marked value
    + '</body>
    </html>'

module.exports = html
