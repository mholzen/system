_ = require 'lodash'
log = require '@vonholzen/log'

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
    @value = value
    @path = path

  and: (match)->
    if not match instanceof Match
      throw new Error "and() with non Match argument"

    if match.input != @input
      throw new Error "and() against non matching inputs"

    if typeof @input == 'string'
      a_index = @path[0] ? 0
      b_index = match.path[0] ? 0
      start = Math.max a_index, b_index
      end = Math.min a_index+@value.length, b_index+match.value.length
      if start >= end
        @value = null
        return null

      @value = @input[start..end]
      @path = [start]
      return @

    if startsWith match.path, @path
      if match.path.length > @path.length
	       # should ensuyre
        {@value, @path} = match
        return @

      if typeof @value = 'string' and typeof match.value == 'string'
        return @

    throw new Error 'unfinished'


class Matches
  constructor: (data)->
    @values = data

ensureMatch = ->
  for k, a of arguments
    if not a?.value?
      throw new Error "no value #{log.print a} for argument #{k}"
    if not a?.path? instanceof Array
      throw new Error "no path array #{log.print a} for argument #{k}"

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

  if a.path.length > b.path.length
    [a, b] = [b, a]

  # a.path short
  # b.path longer
  a_value = a.value
  for b_key, i in b.path
    if i >= a.path.length
      # no more a keys
      if typeof b_key == 'number' and typeof a_value == 'string'
        # handle substring index
        break

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
    if typeof b_key == 'number' and typeof a_value == 'string'
      # numeric index in a string
      end = Math.min a_key + a_value.length, b_key + b.value.length
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
      throw new Error "different values with same path #{log.print [a, b]}"
    return b

  keys = _.intersection(_.keys(a_value), _.keys(b.value))
  if keys.length == 0
    return null

  a_value = _.pick a_value, keys

  b_value = _.pick b.value, keys
  if not _.isEqual a_value, b_value
    throw new Error "different values with same path #{log.print [a, b]}"

  return new Match a_value, b.path

module.exports = {
  startsWith
  Match
  Matches
  intersect
}
