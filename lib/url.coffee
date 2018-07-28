log = require '@vonholzen/log'

url = (from)->
  log 'url', from
  if typeof from == 'string'
    if from.match /https*:\/\/[^/]+/
      return from
    if from.match /\w+\.\w+/
      return "http://#{from}/"

  if from.url?
    return from.url

  if from.path?
    return 'file://' + from.path

module.exports = url
