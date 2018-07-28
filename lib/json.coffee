# returns an array of objects with a value matching the query
search = (source, query, output)->
  if source instanceof Array
    return source.filter (s)-> search s, query

  if typeof source == 'number'
    if source == query
      return source
    return null

  if typeof source == 'string'
    if source.includes query
      return source
    return null

  if typeof source == 'object'
    # does a value match the query?
    for own prop, value of source
      if search value, query
        return source
    return null

expect = require 'expect'
test = ()->
  s=[{a:0}, {b:1}, {c:2}, {d:1}]
  # expect(search(s, 1)).toEqual([{b:1}, {d:1}])

  s={a:0, b:1}
  expect(search(s, 1)).toEqual({a:0}, {b:1})

  s={a:0, b:1}
  expect(search(s, 2)).toEqual(null)

  s=1
  expect(search(s, 1)).toEqual(1)

test()

module.exports =
  search: search
