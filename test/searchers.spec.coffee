{search} = require '../lib/searchers'
query = require '../lib/query'

describe 'searchers', ->

  it 'should find an html graph template', ->
    r = query(/DOCTYPE/).match system.mappers.templates
    path = r[0].path.slice(0,2)
    expect(path).eql ['graph', 'template']

    r = query(/DOCTYPE/).match system.mappers
    expect(r).property(0).property('path').eql ['templates', 'graph', 'template', 2]

    r = query('graph').match system.mappers
    expect(r).property(0).property('path').eql []   # matches graph mapper
    expect(r).property(1).property('path').eql ['templates']

    r = query(['graph', /DOCTYPE/]).match system.mappers
    expect(r).property(0).property('path').eql ['templates', 'graph', 'template', 2]
