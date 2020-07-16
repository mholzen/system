url = require './mappers/url'

open = (value)->
  if value.url?
    exec "open #{value.url}"

module.exports = open
