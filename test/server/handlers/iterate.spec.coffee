{iterate} = require 'server/handlers'
root = require 'server/root'
args = require 'lib/mappers/args'

describe 'servers/handlers/iterate', ->
  it 'iterate,functions.iterators.traverse', ->
    req =
      data: root.functions
      args: args 'functions.iterators.traverse'
      params:
        imports: [root]

    iterate req

    expect await req.data.collect().toPromise Promise
    .property 'length'
    .above 10

