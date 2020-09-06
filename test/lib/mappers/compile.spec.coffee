compile = require '../../../lib/mappers/compile'

describe 'compile', ->
  it 'javascript', ->
    f = compile '1', language: 'javascript'
    expect(f).a 'function'
    expect(f()).eql 1

  it 'pug', ->
    f = compile 'p #{x}', language: 'pug'
    expect(f).a 'function'
    expect(f(x:1)).eql '<p>1</p>'
