post = require '../lib/post'
tempy = require 'tempy'

{stat} = require '../lib/inodes'

describe 'post', ->
  it 'data', ->
    response = await post 'data'
    expect(response.startsWith '/').true

  it 'data to file', ->
    file = tempy.file()
    response = await post 'data', file
    expect(response).equal file

  it 'data to directory', ->
    directory = tempy.directory()
    file = await post 'data', directory
    s = await stat file
    expect s.isFile()
    .true

it 'directory', ->
    container = tempy.directory()
    directory = await post null, container + '/directory/'
    s = await stat directory
    expect s.isDirectory()
    .true
