log = require './log'
table = require './table'
stream = require './stream'
requireDir = require 'require-dir'
creator = require './creator'
parse = require './mappers/parse'

reducers =
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

Object.assign reducers, requireDir './reducers'

stuff = (reducer, options)->
  if typeof reducer == 'function'
    return [ , reducer, ]

  if reducer instanceof Array
    return reducer

  if typeof reducer?.create == 'function'
    res = reducer.create options
    if res instanceof Array
      return res
    return [ , res, ]

  throw new Error "cannot make stuff"

reducers.reduce = (data, name, opts)->

  # semantics of creator...?
  log.debug 'reduce.entry', {data, name, opts}
  if not name of reducers
    throw new Error "cannot find '#{name}' in reducers"
  reducer = reducers[name]

  # do I have a reducer?  or a reducerCreator?
  [memo, memoizer, finisher] = stuff reducer, opts

  if typeof data == 'string'
    data = parse data

  if data instanceof Array
    r = data.reduce memoizer, memo
    if finisher?
      r = finisher r
    return r

  if stream.isStream data
    return data.reduce memo, memoizer
    .map (r)->
      if finisher?
        r = finisher r
      r
    .toPromise Promise

  throw new Error "can't reduce '#{typeof data}' value"


module.exports = creator reducers
