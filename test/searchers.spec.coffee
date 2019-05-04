{search} = require '../lib/searchers'
query = require '../lib/query'

describe 'searchers', ->

  it 'should returns list of mappers', ->
    r = search 'mappers'
    r.toArray (r)->
      # should it contain sub group of mappers?  like all templates?

  it 'should find an html graph template', ->
    r = query(/DOCTYPE/).match system.mappers.templates
    expect(r).property(0).property('path').eql ['graph', 'template']

    r = query(/DOCTYPE/).match system.mappers
    expect(r).property(0).property('path').eql ['templates', 'graph', 'template']

    r = query('graph').match system.mappers
    expect(r).property(0).property('path').eql []   # matches graph mapper
    expect(r).property(1).property('path').eql ['templates']

    r = query(['graph', /DOCTYPE/]).match system.mappers
    expect(r).property(0).property('path').eql ['templates', 'graph', 'template']
