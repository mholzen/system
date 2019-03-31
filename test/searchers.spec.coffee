{search} = require '../lib/searchers'
query = require '../lib/query'

describe 'searchers', ->

  it 'should returns list of mappers', ->
    r = search 'mappers'
    r.toArray (r)->
      # should it contain sub group of mappers?  like all templates?

  it 'should find an html graph template', (done)->
    q = search 'mappers', 'templates', 'graph', 'html'
    q.toArray (r)->
      # should find a resource with a path that can dereferenced from the current context
      expect(r).property(0).property('path').includes 'templates/graph.html'
