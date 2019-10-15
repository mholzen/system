{stream} = require '../lib'
_ = require 'lodash'

it 'should return a stream', ->
  expect(stream()).satisfy stream.isStream
