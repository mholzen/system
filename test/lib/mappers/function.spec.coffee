get = require 'lib/mappers/function'
root = require 'server/root'

describe 'function', ->
  it 'basic', ->
    expect get 'mappers.function', {root}
    .a 'function'

  it 'imports', ->
    expect get 'mappers.function', {imports: [{}, root]}
    .a 'function'
