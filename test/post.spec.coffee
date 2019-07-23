post = require '../lib/post'
tempy = require 'tempy'

it 'should post', ->
  response = await post 'foo'
  expect(response.startsWith '/').true

it 'should post to a file', ->
  file = tempy.file()
  response = await post 'foo', file
  expect(response).equal file

it 'should post to a directory', ->
  directory = tempy.directory()
  response = await post('foo', directory)
  expect(response).not.endsWith '/'
