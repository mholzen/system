{reducers: {reduce, html}} = require '../../../lib'

describe 'reducers/html', ->
  it 'works', ->
    r = reduce [1,2,3], 'html'
    expect(r).include '<p>1</p>'
    expect(r).include '<p>2</p>'
    expect(r).include '<p>3</p>'
