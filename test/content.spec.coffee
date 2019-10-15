{post, mappers: {content}} = require '../lib'

it 'should get a file', ->
  filename = await post 'foo'
  c = await content filename
  expect(c).equal 'foo'
