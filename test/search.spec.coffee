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
    expect(output[0]).property('path').eql ["bookmarks"]

    output = await output[0].value
    output = output.toArray()
    expect(output[0]).property('path').eql [62,"name",0,0]