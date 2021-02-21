set =
  create: ->
    (memo, data)->
      memo ?= new Set()
      memo.add data
      # log.debug 'set', {data, entries: Object.fromEntries memo.entries()}
      return memo

module.exports = set