url = require './url'

open = (value)->
  if value.url?
    exec "open #{value.url}"

module.exports = open
