log = require '../log'
{parse} = require 'node-html-parser'
# import { parse } from 'node-html-parser'

links = (data)->
  # log.debug 'links', {data}
  r = '<link rel="stylesheet" type="text/css" href="/files/index.css"/>'
  if typeof data == 'string'
    r += '<link rel="stylesheet" type="text/css" href="/files/css/'+data+'.css"/>'
  r

head = (html)->
  if (h = html.querySelector 'head')
    return h
  body = html.querySelector 'body'
  if body == null
    throw new Error "no body #{html}"
  body.insertAdjacentHTML 'afterbegin', '<head>'

style = (data, options)->
  if typeof data == 'string'
    html = parse data
    h = head html # ensure there is a head
    html.insertAdjacentHTML 'afterbegin', links options
    data = html.toString()
    # re = /<html> <body>/smg
    # data = data.replace re, '<html><head>'+link+'</head><body>'

  return data

module.exports = style
