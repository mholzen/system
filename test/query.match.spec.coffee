query = require '../lib/query'
{createQuery, fromArgs, Query} = query
{post} = require '../lib'

describe 'query.match', ->
  it 'array', ->
    r = await query(1).match [1, 2, 1]
    expect(r).eql [1,1]

  it 'object value', ->
    r = await query(1).match {a:1, b:2}
    expect(r).eql a:1

  it 'object key', ->
    r = await query('a').match {a:1, b:2}
    expect(r).eql a:1

  it 'stream', ->
    r = await query(1).match stream [1,2,1]
    expect(r).eql a:1


  it 'matches root nodes', ->
    r = await query(['a', 'aa']).match({a:{aa:1}, b:2})
    expect(r).eql({a:{aa:1}, b:2})

  it 'matches leaf nodes', ->
    r = await query(['a', 'aa']).match({a:{aa:1}, b:2})
    expect(r).eql({aa:1})
