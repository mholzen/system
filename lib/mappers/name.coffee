query = require '../query'
path = require 'path'

nameRe = /^((\w+)\.)*(\w+)/g

module.exports = (data)->
  if typeof data == 'string'
    match = data.match nameRe
    if match?
      return match[0]

  matches = query('name').match data
  if matches?
    return matches
  matches = query('path').match data
  if matches?
    return matches.map (m)->path.basename m.value
