{parse} = require 'node-html-parser'

# adds navigation controls to an item of a collection

index = (data, options)->
  # identify current index
  i = parseInt options.i
  if isNaN i
    log.error {options}
    throw new Error 'options.i is not number'   # TODO: use NotMapped

  i

module.exports = (data, options)->
  i = index data, options

  if typeof data == 'string'
    html = parse data
    div = html.querySelector 'div'
    if not div?
      throw new Error "no div #{html}"
    div.insertAdjacentHTML 'beforebegin', '<div class="navigate"><a href=".">back to album</a><div>'
    if i > 1
      div.insertAdjacentHTML 'afterbegin', '<a class="navigate" href="apply,index,' + (i-1) + '?redirect">&lt;</a>'
    div.insertAdjacentHTML 'beforeend', '<a class="navigate" href="apply,index,' + (i+1) + '?redirect">&gt;</a>'
    data = html.toString()

  data

