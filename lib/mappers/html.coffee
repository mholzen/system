log = require '../log'
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


body = (value, options)->
  if value instanceof Array
    value = value.map((x)->"- [#{x}](./#{encodeURI(x)})").join '\n'

  if typeof value?.toString == 'function'
    if (type = options?.res?.get('Content-Type'))?.startsWith 'image/'
      # TODO: may not work for all types?
      return '<img src="data:' + type + ';base64,' + value.toString('base64') + '">'

    value = value.toString()

  if typeof value == 'string'
    return marked value

  if typeof value == 'object'
    value = form value

  # from Markdown to HTML
  return marked value

html = (value, options)->
  if typeof value?.toHtml == 'function'
    return value.toHtml()

  result = '<!DOCTYPE html>
  <html>
  <body>' + body value, options
  + '</body>
  </html>'

  # NOTE: idempotent side effect
  if typeof options?.res?.type == 'function'
    options.res.type 'text/html'

  return result

module.exports = html
