{stream} = require '../lib'
_ = require 'lodash'

describe 'stream', ->
  it '', ->
    expect(stream()).satisfy stream.isStream

  it 'promise', ->
    p = new Promise (resolve, reject)-> resolve 1
    s = stream p
    r = await s.collect().toPromise Promise
    expect(r).eql [1]
