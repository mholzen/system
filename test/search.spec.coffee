{search} = require '../lib'

describe 'search', ->

  it '', ->
    output = search 'foo'
    expect(output).not.null

  it 'two arguments', ->
    output = search ['jira', 'projects']
    expect(output).not.null
