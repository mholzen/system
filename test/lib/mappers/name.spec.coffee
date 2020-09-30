{all} = require '../../../lib/mappers'

name = all.name

describe 'name', ->
  it 'works', ->
    expect name 'Marc von Holzen'
    .eql first: 'Marc', last: 'Von Holzen'
