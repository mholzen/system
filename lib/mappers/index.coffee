
{NotMapped, NotFound} = require '../errors'
content = require './content'
{parse} = require 'node-html-parser'

{format} = require 'url'

fullUrl = (req, path)->
  format
    protocol: req.protocol,
    host: req.get 'host'
    pathname: path

module.exports = (data, index, options)->
  # identify index
  i = parseInt index
  if isNaN i
    throw new NotMapped index, 'i'

  # identify collection
  path = options.req.base
  if path instanceof Array
    path = '/' + path.join '/'

  if path.endsWith '/'
    path += 'index.pug/apply/pug'
  
  url = fullUrl options.req, path
  collection = await content {url}
  root = parse collection

  # identify item
  item = root.querySelector ('#' + i)

  if not item?
    throw new NotFound i, root.querySelectorAll('*[id]').map (x)-> x.toString()

  redirect = item.attributes.href
  # log.debug 'redirecting', {url, i, redirect}
  # options.res.redirect redirect