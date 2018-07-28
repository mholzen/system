module.exports =

h = require 'highland'
log = require '@vonholzen/log'
parse = require './parse'

module.exports =
  parse: -> h.pipeline(
    h.split()
    h.filter (line) -> line.length > 0
    h.map parse
  )

  write: ->
    h.pipeline(
      h.apply (memo)->
        if typeof memo == 'object'
          memo = JSON.stringify memo
        process.stdout.write memo + '\n'
    )
