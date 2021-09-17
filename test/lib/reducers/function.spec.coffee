functionReducer = require 'lib/reducers/function'
{identify, get} = require 'lib/mappers'

###
Q: How to distinguish between creating a mapper that takes a literal or a function

Eg:
  join '-'
  join inc 'x'
Eg:
  get 'foobar'
  get reverse 'foobar'

Except `join` should be a reducer.
  Which does not make a difference, the creator still can accept a string or a function

join.create = (string or function returning a string)->

A: everything only takes a function, use a function to return a string

Eg:  join generator.dash
     get literals.foobar

###

root =
  augment:
    create: (fn, options)->
      (d, o)->
        value = fn d
        name = identify value, fn, options
        Object.assign d, {name: value}
        # d[name] = value

  join:
    create: (separator)->
      (d)-> d.join separator

  literals: (data)->return data

  dash: -> '-'
  get: get

describe 'reducers/function', ->
  it 'works', ->
    f = ['augment', 'join', 'dash'].reduceRight functionReducer.create(root), null

    expect f ['1', '2']
    .eql ['1','2']
    .property 'name', '1-2'

  it 'using create explicitely', ->
    f = [['augment', 'create'], ['join', 'create'], 'dash'].reduceRight functionReducer.create(root), null

    expect f ['1', '2']
    .eql ['1','2']
    .property 'name', '1-2'

  it 'accepts a string', ->
    f = ['get', ['literals','foobar']].reduceRight functionReducer.create(root), null

    expect f {foobar: 1}
    .eql 1

  it.skip 'fails', ->
    f = ['apply','reducers.inject','.files.test.artifacts.table.pug'].reduceRight functionReducer.create(root), null

    expect f
    .a 'function'