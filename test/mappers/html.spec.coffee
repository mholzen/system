{html} = require '../../lib/mappers'

describe 'html', ->
  it 'accepts markdown', ->
    expect html '# Foo'
    .include '<h1 id="foo">Foo</h1>'

  it.skip 'handles requests', ->
    # html handler should convert an image to an <img> tag
    data = "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

    res = html data, res, req
    expect res.data
    .include '<img'
