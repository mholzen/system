{stream} = require '../lib'
_ = require 'lodash'

describe 'stream', ->
  it 'isStream', ->
    expect(stream()).satisfy stream.isStream

  it 'promise', ->
    p = new Promise (resolve, reject)-> resolve 1
    s = stream p
    r = await s.collect().toPromise Promise
    expect(r).eql [1]

  it 'write to stream being processed', ->
    s = stream [1,2,3]
    r = s.doto (x)->
      if x == 1 then s.write 11
   
    r = await r.collect().toPromise Promise
    expect(r).eql [11, 1, 2, 3]
  
  it 'generator functions', ->
    next = 
    s = stream (push, next)->
      push null, 1
      # next()
      push null, 2
      # next()
      push null, 3
      push null, stream.nil
      # next()
    r = await s.collect().toPromise Promise
    expect(r).eql [1,2,3]