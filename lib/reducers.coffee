log = require './log'
table = require './table'
stream = require './stream'
requireDir = require 'require-dir'
creator = require './creator'

reducers =
  reduce: (data, name, opts)->
    reducer = reducers[name] opts
    if data instanceof Array
      r = data.reduce reducer[1], reducer[0]
      if reducer[2]
        r = reducer[2] r
      return r

    if stream.isStream data
      return data.reduce reducer[0], reducer[1]
      .map (r)->
        if reducer[2]
          r = reducer[2] r
        r
      .toPromise Promise
    throw new Error "can't reduce '#{typeof data}' value"

  count: -> [
    0,
    (memo, value)->
      # log.debug 'count', {memo, value}
      if value?
        memo = memo + 1
      memo
    ]

  defined: (out)->
    [
      undefined
      (memo, value)->
        if value?
          memo.push value
        memo.next()
        log 'defined', {value}
        memo
    ]

  join: (options)->
    delimeter = options.delimeter ? ', '
    [
      undefined
      (memo, value)->
        return value if not memo?
        return memo if not value?
        return memo + delimeter + value
    ]

  object: (opts)->
    count = 0
    [
      {}
      (memo, value)->
        if typeof value == 'object'
          Object.assign memo, value
        if value?
          memo[count] = value
          count++
        memo
    ]

  random: ->
    count = 0
    [
      null
      (memo, value)->
        if value?
          count = count + 1
        log 'random', {value, probability: 1/count}
        if Math.random() < 1/count
          memo = value
        memo
    ]

  string: (opts)->
    [
      null
      (memo, value)->
        (memo ? '') + value
    ]

  table: (opts)->
    [
      new table.Table()
      (table, value)->
        table.add value
        table
    ]

v = Object.assign reducers, requireDir './reducers'
module.exports = creator v

# module.exports = creator Object.assign reducers, requireDir './reducers'
