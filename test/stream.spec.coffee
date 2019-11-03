{stream} = require '../lib'
_ = require 'lodash'

describe 'stream', ->
  it '', ->
    expect(stream()).satisfy stream.isStream
