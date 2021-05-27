mappers = require '../mappers'

map =
  create: (options)->
    # log.debug 'map.create', {options}
    key = if options?.key? then options?.key else options[0]

    if typeof key == 'boolean'
      key = if key then 1 else 0

    if typeof key == 'number'
      n = key
      key = (x)->
        x[n]

    if typeof key == 'string'
      if not (key of mappers.all)
        key = mappers.get.create key
      else
        key = mappers key, options

    (memo, data)->
      # log.debug 'map.entry', {key, memo, data}
      memo ?= new Map()
      k = key data

      values = if memo.has(k) then memo.get(k) else []
      values.push data
      memo.set k, values

      # log.debug 'map.exit', {entries: Object.fromEntries memo?.entries()}
      return memo

module.exports = map