post = require '../lib/post'
tempy = require 'tempy'

{statAsync} = require '../lib/inodes'

it 'should post', ->
  response = await post 'foo'
  expect(response.startsWith '/').true

it 'should post to a file', ->
  file = tempy.file()
  response = await post 'foo', file
  expect(response).equal file

it 'should post to a directory', ->
  directory = tempy.directory()
  file = await post 'foo', directory
  stat = await statAsync file
  expect stat.isFile()
  .true

it 'should post to a file in a directory', ->
  directory = tempy.directory()
  file = await post 'foo', directory + '/file'
  stat = await statAsync file
  expect stat.isFile()
  .true
