{stream} = require '../lib'
{Match} = require '../lib/match'


it 'flatten', ->
  # flatten = transform.flatten()
  r = await stream [1, [1, 2]]
  .flatten()
  .collect().toPromise Promise

  expect(r).eql [1,1,2]

it 'flatten matches', ->
  # flatten = transform.flattenMatches()
  isMatch = (x)->
    (x.path instanceof Array) and ('value' of x)
  expect(isMatch {value:{value:1, path:['a']}, path: ['b']}).true

  flatten = (x)->
    if x instanceof Array
      return x.map flatten
    if not isMatch x
      return x
    # x isMatch
    if x.value instanceof Array
      return x.value.map (m)->
        if not isMatch m
          return m
        # here to flatten deep
        (new Match m.value, m.path).prepend x.path

    if not isMatch x.value
      return x
    # x.value isMatch
    m = new Match x.value.value, x.value.path
    return m.prepend x.path

  expect(flatten {value:{value:1, path:['a']}, path: ['b']})
  .eql {value: 1, path: ['b', 'a']}

  v = {value:[
    {value:1, path:['a']}
    {value:2, path:['b']}
    ], path: ['c']}

  expect(flatten v).eql [
    {value: 1, path: ['c', 'a']}
    {value: 2, path: ['c', 'b']}
  ]

  v = [{value:[{value:1, path:['a']}], path: ['b']}]
  expect(flatten v[0]).eql [{value: 1, path: ['b', 'a']}]

  s = stream v
  .flatMap flatten
  r = await s.collect().toPromise Promise
  expect(r).eql [{value: 1, path: ['b', 'a']}]
