marked = require 'marked'
url = require './url'
json = require './json'

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
    # log.debug 'html', {data}
    (tr v, k for k, v of data when data.hasOwnProperty k)

form = (data)->
  '<table class="table table-sm table-responsive table-hover table-bordered">' +
  (rows(data).join '') +
  '</table>'

li = (data, options)->
  '<li>' + body(data, options) + '</li>'

ul = (data, options)->
  '<ul>' +  data.map(li).join("\n") + '</ul>'

body = (value, options)->
  if value instanceof Array
    # value = value.map((x)->"- [#{x}](./#{encodeURI(x)})").join '\n'
    return ul value, options

  if value?.image?.src?
    return '<div><img src="'+ encodeURI(value.image.src) + '"></img></div>'

  if value?.a?.href?
    return '<a href="'+ encodeURI(value.a.href) + '">' + value.a.text + '</a>'

  type = options?.res?.get 'Content-Type'
  if type?.startsWith 'image/'
    # TODO: if we get a stream, do what?
    # TODO: fix new Buffer
    return '<div><img src="data:' + type + ';base64,' + (Buffer.from(value)).toString('base64') + '"></div>'

  if value instanceof Buffer
    value = value.toString()

  if typeof value == 'string'
    return marked value

  if typeof value == 'object'
    value = form value
    return marked value

  if typeof value?.toString == 'function'
    value = value.toString()

  # from Markdown to HTML
  if not value?
    value = ''
  return marked value

base = (href)->
  if not href?
    return ''

  if href instanceof Array
    href = '/' + href.join '/'

  '<base href="' + encodeURI(href) + '">'

style = (data)->
  if not data?.url?
    data.url = url data

  if data?.url?
    # return '<link href="' + data.url + '" rel="stylesheet" type="text/css">'
    return '<link href="' + data.url + '" rel="stylesheet">'

head = (data)->
  result = ''
  # if data?.req?.base
  #   result += base data.req.base
  if data?.style?
    result += style data.style
  result

outer = (data, options)->
  '<!DOCTYPE html>
  <html>' + head(options) + '
  <body>' + body(data, options) + '</body>
  </html>'

html = (data, options)->
  if typeof data?.toHtml == 'function'
    return data.toHtml()

  result = outer data, options
  return result

type = (data, options)->
  result = html data, options

  if result?
    if typeof options?.res?.type == 'function'
      options.res.type 'text/html'

  return result

module.exports = Object.assign type, {body, outer, base}
