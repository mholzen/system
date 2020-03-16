{search, post, query, stream, inodes, mappers} = require '../lib'
{outputter} = require '../lib'
{dirname, basename} = require 'path'

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

describe 'searchIn', ->
  it 'searchIn basic', ->
    content = (x)-> if x == 22 then 1 else null

    data = stream [1,22,3]
    results = search.searchIn query(1), query(22), data, {content}
    output = await results.collect().toPromise Promise
    expect(output).eql [1, 1]

  it 'searchIn directories', ->
    followDirectories = query type:'directory'
    files = inodes().entries()
    results = search.searchIn query(true), followDirectories, files, {content: mappers.content}
    output = await results.map(mappers.get.getter('path')).collect().toPromise Promise
    expect(output).length.above 10

  it 'follow:foo.json', ->
    file = await post {name: 'Marc'}, {type: 'directory'}
    directory = dirname file
    name = basename file
    followAll = query true
  
    output = search.searchIn query('Marc'), followAll, inodes(directory).entries(), {content: mappers.content}
    expect(stream.isStream output).true
    output = await output.collect().toPromise Promise
       
    expect(output).eql [name:'Marc']
  