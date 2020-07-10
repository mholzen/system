{pug} = require '../lib/mappers'
query = require '../lib/query'

describe 'tempates', ->
  describe 'graph', ->
    it 'should find an html graph template', ->
      r = query(/DOCTYPE/).match mappers.templates
      path = r[0].path.slice(0,2)
      expect(path).eql ['graph', 'template']

      r = query(/DOCTYPE/).match mappers
      expect(r).property(0).property('path').eql ['templates', 'graph', 'template', 2]

      r = query('graph').match mappers
      expect(r).property(0).property('path').eql []   # matches graph mapper
      expect(r).property(1).property('path').eql ['templates']

      r = query(['graph', /DOCTYPE/]).test mappers
      expect(r).true

  describe 'pug', ->
    it 'works', ->
      expect pug null, template:'doctype html'
      .eql '<!DOCTYPE html>'

      expect pug {a:1}, template:'p #{a}'
      .eql '<p>1</p>'
