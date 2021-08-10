_ = require 'lodash'

describe 'find', ->
  it 'finds synchronoulsy', ->
    paths = [
      {a:1}
      {a:{b:2}}
      {a:{b:{c:3}}}
    ]

    # mappers.get should be a reducer
    get =
      create: (path)->
        (data)->
          _.get data, path

    findIndex = (paths, path)->
      f = get.create path
      paths.findIndex f

    expect findIndex paths, 'a.b.c'
    .eql 2

    # TODO: findIndex is an operation of a collection
    expect paths.findIndex get.create 'a.b.c'
    .eql 2

    # /paths/apply,findIndex,get.create,a.b.c