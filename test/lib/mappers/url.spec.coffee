{url} = require 'lib/mappers'

describe 'url', ->
  it 'works', ->
    expect url 'vonholzen.org'
    .eql 'https://vonholzen.org'

  it 'correctly throws', ->
    expect -> url 'blah'
    .throws()
    .property 'data', 'blah'
