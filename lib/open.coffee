url = require './map/url'

open = (value)->
  if value.url?
    exec "open #{value.url}"

module.exports = open
