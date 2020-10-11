{reduce} = require '../../../lib/reducers'

describe 'reducers/graph', ->
  it 'works', ->
    r = reduce [[], []], 'graph'
    expect(r).respondTo 'nodes'
    expect(r).respondTo 'edges'
