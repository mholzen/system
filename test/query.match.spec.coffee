query = require '../lib/query'
{createQuery, fromArgs, Query} = query
{post} = require '../lib'

describe 'query.match', ->
  it 'from empty', ->
    r = await query().match 'abc'
    expect(r).eql 'abc'

  it 'string', ->
    r = await query('a').match 'abc'
    expect(r).eql null
    r = await query('a').match ['a', 'b']
    expect(r).eql ['a']
    r = await query('-a').match ['a', 'b']
    expect(r).eql ['b']

  it 'regexp', ->
    r = await query(/a/).match 'abc'
    expect(r).property 0,  'a'
    r = await query(/a/).match ['a', 'b']
    expect(r).eql ['a']

  it 'array', ->
    r = await query(1).match [1, 2, 1]
    expect(r).eql [1,1]

  it 'from array', ->
    r = await query([]).match 'abc'
    expect(r).eql 'abc'
    r = await query([/a.c/, /.b./]).match 'abc'
    expect(r).property(0).property 0, 'abc'
    r = await query([/a/, /d/]).match 'abc'
    expect(r).null
    r = await query([{a:1}, 2]).match {a:1}
    expect(r).null

  it 'object value', ->
    r = await query(1).match {a:1, b:2}
    expect(r).eql a:1
    r = await query(['marc', 'von holzen']).match {first:'marc', last:'von holzen'}
    expect(r).property(0).includes first:'marc'
    expect(r).property(0).includes last:'von holzen'

  it 'object key', ->
    r = await query('a').match {a:1, b:2}
    expect(r).includes a:1

  it 'object key', ->
    r = await query({a:1}).match {a:1, b:2}
    expect(r).eql a:1

  it.skip '-string on object key', ->
    # TODO: -a matches the value :1
    r = await query('-a').match {a:1, b:2}
    expect(r).eql b:2

  it.skip '-string on object value', ->
    # key 'a' matches '-1' so it returns it too
    r = await query('-1').match {a:'1', b:2}
    expect(r).eql b:2

# TODO: match against streams
