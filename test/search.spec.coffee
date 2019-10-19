{search} = require '../lib'

describe 'search', ->

  it '()', ->
    output = search 'google'
    log.debug {output}
    expect(output).not.null
