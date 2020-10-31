{Results} = require  'lib/results'
log = require  'lib/log'

describe 'Results', ->

  it 'constructor', ->
    a = new Results [[ ['a'], 1 ]]
    expect(a.toArray()).eql [{path:['a'], value:1}]

  it 'prepend', ->
    a = new Results [[ [], 1 ]]
    a.prepend('a').prepend('b').prepend ['d', 'c']
    expect(Array.from a.values).eql [[['d', 'c','b','a'], 1]]

  it 'toArray', ->
    a = new Results [[ [], 1 ]]
    expect(a.toArray()).eql [{path:[], value:1}]