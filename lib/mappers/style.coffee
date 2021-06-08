{parse} = require 'node-html-parser'

links = (data)->
  # log.debug 'links', {data}

  r = ''
  # r = '<link rel="stylesheet" type="text/css" href="/files/index.css"/>'
  # r += '<link rel="stylesheet" type="text/css" href="./index.css"/>'

  if typeof data == 'string'
    r += '<link rel="stylesheet" type="text/css" href="/files/css/'+data+'.css"/>'

  r

head = (html)->
  if (h = html.querySelector 'head')
    return h
  body = html.querySelector 'body'
  if body == null
    throw new Error "no body #{html}"
  body.insertAdjacentHTML 'beforebegin', '<head>'
  html.querySelector 'head'

style = (data, options)->
  if typeof data == 'string'
    html = parse data
    h = head html # ensure there is a head
    # log.debug 'html', {html}
    h.insertAdjacentHTML 'beforeend', links options
    data = html.toString()

  return data

module.exports = style
