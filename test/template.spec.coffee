template = require  'lib/mappers/template'
template2 = require  'lib/mappers/template2'
content = require  'lib/mappers/content'
pug = require  'lib/mappers/templates/pug'
inject = require 'lib/reducers/inject'

describe 'template', ->
  it 'expressions substitute', ->
    t = template.create 'foo ${a} ${b} bar'
    # expect(t.substitutions).eql ['a','b']       # TODO: should not include #{}
    expect(t({a:1, b:2})).eql 'foo 1 2 bar'

  it 'accepts a path', ->
    t = pug await content path: 'test/artifacts/template.pug'
    expect t
    .property 'template', 'p a:#{a} b:#{b}'

    expect t.substitute {a:1, b:2}
    .eql '<p>a:1 b:2</p>'

  it.skip 'injects', ->
    expect await inject {a:1, b:2}, {path: 'test/artifacts/template.pug'}
    .eql '<p>a:1 b:2</p>'
