query = require '../query'
path = require 'path'

module.exports = ->
  (data)->
    matches = query('name').match data
    if matches?
      return matches
    matches = query('path').match data
    if matches?
      return matches.map (m)->path.basename m.value
