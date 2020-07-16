pug = require '../../lib/reducers/pug'

describe 'pug', ->
  it 'pug', ->
    [memo, reducer] = pug template: 'p a:#{a}'

    expect reducer {a:1}
    .eql '<p>a:1</p>'