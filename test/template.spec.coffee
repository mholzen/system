{substitute, Template} = require '../lib/mappers/template'

describe 'template', ->
  it 'expressions substitute', ->
    t = new Template 'foo #{a} #{b} bar'
    expect(t.expressions()).eql ['#{a}','#{b}']       # TODO: should not include #{}
    expect(t.substitute({a:1, b:2})).eql 'foo 1 2 bar'

  it 'template.substitute', ->
    t = substitute 'a:1', 'b:2'
    expect(t template: '#{a} #{b}').eql '1 2'
