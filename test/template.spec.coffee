{Template} = require '../lib/map/template'

describe 'template', ->
  it 'expressions', ->
    t = new Template 'foo #{a} #{b} bar'
    # TODO: should not include #{}
    expect(t.expressions()).eql ['#{a}','#{b}']
