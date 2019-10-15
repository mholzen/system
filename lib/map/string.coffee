
module.exports = ->
  (value)->
    if typeof value == 'object'
      if typeof value?.toJSON == 'function'
        value = value.toJSON()
      if value instanceof Set
        value = value.values()
      value = JSON.stringify value
    value
