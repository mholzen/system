{search} = require '../lib'

describe 'search', ->

  it '', ->
    output = search 'foo'
    expect(output).not.null

  it 'two arguments', ->
    output = search ['^.*jira.*$', '^.*projects.*$']
    output = await output.collect().toPromise Promise
    output = output.flat()
    expect(output).property('length').above(0)
    r = output.find (result)->result.path.includes 'bookmarks'
    expect(r).property('value').property('values').a('map').include 'jira projects'