set =
  create: ->
    (result, item)->
      result ?= new Set()
      result.add item
      log.debug {item, v: Object.fromEntries result.entries()}
      return result

module.exports = set