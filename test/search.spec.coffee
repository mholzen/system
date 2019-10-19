{search} = require '../lib'

describe 'search', ->

  it '()', ->
    output = search 'foo'
    expect(output).not.null
