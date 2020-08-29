log = require '@vonholzen/log'
marked = require 'marked'

json = require './json'
# table = require './table'

# escape = (data)->
#   data
#   .replace(/&/g, "&amp;")
#   .replace(/</g, "&lt;")
#   .replace(/>/g, "&gt;")
#   .replace(/"/g, "&quot;")
#   .replace(/'/g, "&#039;")

ids = {}

key = (k)->
  if ids[k]?
    "<a href='#{ids[k]}'>#{k}</a>"
  else
    "#{k}"

value = (v, k)->
  if v == null
    return '<em>null</em>'
  if v instanceof Date
    return v.toString()
  if typeof v == 'function'
    return '<em>function</em>'
  if typeof v == 'object'
    return form v
  if ids[k]? and v?
    return "<a href='#{ids[k]}/#{escape v}'>#{v}</a>"
  if /https?:\/\//.test v
    return "<a href='#{v}'>#{v}</a>"

  "#{escape v}"

tr = (v, k)->
  if not k?
    "<tr><td>#{value v}</td></tr>"
  else
    "<tr><td>#{key k}</td><td>#{value v, k}</td></tr>"

rows = (data)->
  if data instanceof Array
    (tr v for v in data)
  else
    log.debug 'html', {data}
    (tr v, k for k, v of data when data.hasOwnProperty k)

form = (data)->
  '<table class="table table-sm table-responsive table-hover table-bordered">' +
  (rows(data).join '') +
  '</table>'

html = (value, options)->
  if typeof value?.toHtml == 'function'
    return value.toHtml()

  if value instanceof Buffer
    if options.filename.endsWith '.md'
      return marked value.toString()

    # detect type
    if ['[', '{'].includes value.toString()[0]
      value = JSON.parse value.toString()
    else
      # TODO: should not infer jpg as type
      value = '<div class="a"><img src="data:image/jpeg;base64,' + value.toString('base64') + '"></div>'

  if value instanceof Array
    value = value.map((x)->"- [#{x}](./#{encodeURI(x)})").join '\n'

  if typeof value == 'object'
    # value = "<p><pre>#{escapeHtml json(value, space:2)}</pre></p>"
    value = form value

  return '<!DOCTYPE html>
  <html>
  <body>' + marked value
  + '</body>
  </html>'

module.exports = html
