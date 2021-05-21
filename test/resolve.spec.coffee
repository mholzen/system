resolve = require  'lib/resolve'
stream = require  'lib/stream'

describe 'resolve', ->
  it 'promise', ->
    p = new Promise (resolve, reject)->resolve 1
    resolve p
    .then (a)->
      expect(a).eql 1

  it 'stream', ->
    s = stream [1,2,3]
    resolve s
    .then (a)->
      expect(a).eql [1,2,3]

  it 'object', ->
    a =
      p1: new Promise (resolve, reject)->resolve 1
      p2: new Promise (resolve, reject)->resolve 2

    resolve a
    .then (a)->
      expect(a).eql
        p1: 1
        p2: 2

  it 'deep', ->
    a =
      a:
        p: new Promise (resolve, reject)->resolve 1
      b:
        p: new Promise (resolve, reject)->resolve 2
        s: stream [1,2,3]

    resolve.deep a
    .then (a)->
      expect(a).eql
        a:
          p: 1
        b:
          p: 2
          s: [1,2,3]

  it 'promise stream', ->
    p = new Promise (resolve, reject)->resolve stream [1,2,3]
    resolve p
    .then (a)->
      expect(a).eql [1,2,3]
