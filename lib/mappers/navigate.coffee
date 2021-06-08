{parse} = require 'node-html-parser'

#TODO: should identify the collection?

module.exports = (data, options)->
  i = parseInt options.i
  if isNaN i
    log.error {options}
    throw new Error 'options.i is not number'   # TODO: use NotMapped

  if typeof data == 'string'
    html = parse data
    div = html.querySelector 'div'
    if not div?
      throw new Error "no div #{html}"
    div.insertAdjacentHTML 'beforebegin', '<div class="navigate"><a href="apply,collection">&#708;</a><div>'
    if i > 1
      div.insertAdjacentHTML 'afterbegin', '<a class="navigate" href="apply,index,' + (i-1) + '">&lt;</a>'
    div.insertAdjacentHTML 'beforeend', '<a class="navigate" href="apply,index,' + (i+1) + '">&gt;</a>'
    data = html.toString()

  data
