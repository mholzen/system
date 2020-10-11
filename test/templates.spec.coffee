mappers = require '../lib/mappers'
pug = mappers.pug
query = require '../lib/query'

describe 'tempates', ->
  describe 'pug', ->
    it 'works', ->
      expect pug null, template:'doctype html'
      .eql '<!DOCTYPE html>'

      expect pug {a:1}, template:'p #{a}'
      .eql '<p>1</p>'
