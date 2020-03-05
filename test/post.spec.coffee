{stream, post, mappers: {content}} = require '../lib'
tempy = require 'tempy'

{stat} = require '../lib/inodes'

describe 'post', ->
  it 'string', ->
    response = await post 'data'
    expect(response.startsWith '/').true

  it 'string to file', ->
    file = tempy.file()
    response = await post 'data', file
    expect(response).equal file

  it 'string to directory', ->
    directory = tempy.directory()
    file = await post 'data', directory
    s = await stat file
    expect s.isFile()
    .true

it 'directory by name', ->
    container = tempy.directory()
    directory = await post null, container + '/directory/'
    s = await stat directory
    expect s.isDirectory()
    .true

it 'directory by type', ->
    directory = await post null, {type: 'directory'}
    s = await stat directory
    expect s.isDirectory()
    .true

it 'stream to file', ->
  file = tempy.file()
  data = stream ['da', 'ta']
  response = await post data, file
  expect(response).equal file
  c = await content file
  expect(c).equal 'data'
