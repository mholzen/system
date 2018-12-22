post = require '../lib/post'
tempy = require 'tempy'

it 'should post', ->
  response = await post('foo')
  expect(response.startsWith '/').true

it 'should post to a file', ->
  file = tempy.file()
  response = await post('foo', file)
  expect(response).equal file

it.skip 'should post to an url', ->
  url = 'http://localhost:8000/abc'
  response = await post(url, 'foo')
  expect(response.statusCode).equal(200)
