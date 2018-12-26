post = require '../lib/post'
tempy = require 'tempy'

it 'should post', ->
  response = await post('foo')
  expect(response.startsWith '/').true

it 'should post to a file', ->
  file = tempy.file()
  response = await post('foo', file)
  expect(response).equal file
