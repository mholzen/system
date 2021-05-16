template = require  'lib/mappers/template'

describe 'template', ->
  it 'expressions substitute', ->
    t = template.create 'foo ${a} ${b} bar'
    # expect(t.substitutions).eql ['a','b']       # TODO: should not include #{}
    expect(t({a:1, b:2})).eql 'foo 1 2 bar'