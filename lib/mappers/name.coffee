query = require '../query'
path = require 'path'
log = require '../log'

capitalize = (string)->
  string.charAt(0).toUpperCase() + string.slice(1)

nameRe = /^(\w+)(?:[\s\.]*)(\w*)/

module.exports = (data)->
  if typeof data == 'string'
    match = data.match nameRe
    if match?
      log.debug {match}
      res = first: capitalize match[1]
      if match[2]?.length > 0
        res.last = capitalize match[2], a:'lastName'
      return res

  matches = query('name').match data
  if matches?
    return matches
  matches = query('path').match data
  if matches?
    return matches.map (m)->path.basename m.value
