{graph} = require '../lib/map/templates'

describe 'graph', ->
  it 'is template', ->
    expect(graph).property('expressions').a 'function'
