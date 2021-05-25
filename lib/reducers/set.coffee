set =
  create: ->
    (memo, data)->
      # log.debug 'set.entry', {memo, data}
      memo ?= new Set()
      memo.add data

      # log.debug 'set.exit', {entries: Object.fromEntries memo?.entries()}
      return memo

module.exports = set