{html} = require '../../../lib/mappers'

describe 'html', ->
  it 'accepts markdown', ->
    expect html '# Foo'
    .include '<h1 id="foo">Foo</h1>'

  it 'handles requests', ->
    # html handler should convert an image to an <img> tag
    req =
      data: "data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mNkYPhfDwAChwGA60e6kgAAAABJRU5ErkJggg=="

    res =
      get: -> 'image/png'

    result = html req.data, {res, req}
    expect result, {res}
    .include '<img'
