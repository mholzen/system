{Template} = require '../lib/map/template'

describe 'template', ->
  it 'expressions substitute', ->
    t = new Template 'foo #{a} #{b} bar'
    # TODO: should not include #{}
    expect(t.expressions()).eql ['#{a}','#{b}']
    expect(t.substitute({a:1, b:2})).eql 'foo 1 2 bar'
