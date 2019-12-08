_ = require 'lodash'
log = require './log'

ensureArray = (a)->
  if not (a instanceof Array)
    throw new Error "startsWith with #{log.print a}"

startsWith = (a,b)->
  ensureArray a
  ensureArray b

  for item, i in b
    if a[i] != item
      return false
  true

isRegeExpAnswer = (a)->
  typeof a?[0] == 'string' and
  typeof a?.index == 'number' and
  typeof a?.input == 'string'


class Match
  constructor: (value, path)->
    if value instanceof Match
      @value = value.value
      @path = path.concat value.path ? []
      return

    @value = value
    @path = path ? []

  prepend: (path)->
    if not (path instanceof Array)
      path = Array.from path
    @path = path.concat @path
    @

  @toMatch: (d)-> return if d instanceof Match then d else new Match d

class Matches
  constructor: (data)->
    @values = data

ensureMatch = ->
  for k, a of arguments
    if not a?.value?
      throw new Error "no value in '#{log.print a}' for argument #{k}"
    if not a?.path? instanceof Array
      throw new Error "no path array in '#{log.print a}' for argument #{k}"

intersect = (a,b)->
  log.debug 'intersect', {a, b}
  if a instanceof Array
    return a.reduce (r, m)->
      if (m = intersect m, b) != null
        r = r ? []
        if b instanceof Array
          r = r.concat m
        else
          r.push m
      r
    , null

  if b instanceof Array
    return intersect b, a

  ensureMatch a, b

  if _.isEqual a.path, b.path
    if not _.isEqual a.value, b.value
      throw new Error "different values with same path (path:#{log.print a.path} a:#{log.print a.value} b:#{log.print b.value})"
    return a

  if a.path.length > b.path.length
    [a, b] = [b, a]

  # a.path short
  # b.path longer
  a_value = a.value
  for b_key, i in b.path
    if i >= a.path.length
      # no more a keys
      if typeof b_key == 'number' and typeof a_value == 'string'
        # TODO: DRY up with code below
        # numeric index in a string
        start = Math.max a_key, b_key
        end = Math.min a_key + a_value.length, b_key + b.value.length
        if start >= end
          return null
        if a_key > b_key
          value = a_value[.. end - a_key - 1]
          return new Match value, a.path
        else
          value = b.value[.. end - b_key - 1]
          return new Match value, b.path

      if typeof a_value != 'object'
        throw new Error "key '#{b_key}' references non object value '#{a_value}'"

      if a_value.hasOwnProperty b_key
        a_value = a_value[b_key]
        continue

      return null

    a_key = a.path[i]

    if b_key == a_key
      continue

    # key mismatch

    if typeof b_key == 'object'
      if typeof b.value != 'object'
        throw new Error "b_key is object but '#{b.value}' is not"
      if typeof a_value != 'object'
        return null
        throw new Error "b_key is object but a_value '#{a_value}' is not. #{log.print {a,b}}"

      v = {}
      p = {}
      for key, path of b_key
        a = new Match a_value[key], a_key[key]
        b = new Match b.value[key], path
        i = intersect a, b
        if i != null
          v[key] = i.value
          p[key] = i.path
      if _.isEmpty v
        return null

      return new Match v, [p]

    if typeof b_key == 'string' and typeof a_key == 'object'
      if not a_value.hasOwnProperty b_key
        return null
      a_value = a_value[b_key]
      if not a_key.hasOwnProperty b_key
        throw new Error "no '#{b_key}' in '#{a_key}'"
      a_key = a_key[b_key]
      b_key = b.path[i+1]   # TODO: error check

    if typeof b_key == 'number' and typeof a_value == 'string'
      # TODO: DRY up with code above
      # numeric index in a string
      start = Math.max a_key, b_key
      end = Math.min a_key + a_value.length, b_key + b.value.length
      if start >= end
        return null
      if a_key > b_key
        value = a_value[.. end - a_key - 1]
        return new Match value, a.path
      else
        value = b.value[.. end - b_key - 1]
        return new Match value, b.path

    # different keys
    return null

  # intersect a_value and b.value
  if typeof a_value != typeof b.value
    return null

  if (typeof a_value != 'object') and (typeof b.value != 'object')
    if a_value != b.value
      throw new Error "different values with same path path:#{log.print a.path} a:#{log.print a} b:#{log.print b}"
    return b

  keys = _.intersection(_.keys(a_value), _.keys(b.value))
  if keys.length == 0
    return null

  a_value = _.pick a_value, keys

  b_value = _.pick b.value, keys
  if not _.isEqual a_value, b_value
    throw new Error "different values with same path #{log.smallPrint [a, b]}"

  return new Match a_value, b.path

module.exports = {
  startsWith
  Match
  Matches
  intersect
}
