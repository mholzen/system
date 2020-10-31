{mappers} = require  'lib'

describe 'pug', ->
  it 'works', ->
    expect mappers.pug {a:1, b:2}, template: 'p a:#{a} b:#{b}'
    .eql '<p>a:1 b:2</p>'

  it 'post data', ->
    mappers.pug.post 'example', 'p a:#{a} b:#{b}'

    expect mappers.pug.example {a:1, b:2}
    .eql '<p>a:1 b:2</p>'

  it 'post path', ->
    template = await mappers.content {path: 'test/artifacts/template.pug'}, parse: false
    mappers.pug.post 'example', template

    expect mappers.pug.example {a:1, b:2}
    .eql '<p>a:1 b:2</p>'