{stream} = require '../lib'
_ = require 'lodash'

describe 'stream', ->
  it '', ->
    expect(stream()).satisfy stream.isStream

  it 'promise', ->
    p = new Promise (resolve, reject)-> resolve 1
    s = stream p
    console.log await s.collect().toPromise Promise
