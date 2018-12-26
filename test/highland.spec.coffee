_ = require 'highland'

describe 'highland', ()->
  it 'write to pipe', ->
    a = _()
    a.write 'abc'
    a.end()
    expect(a.write.bind('dev')).throw()

  it 'empty stream', (done)->
    s = _()
    s.end()   # required on empty stream to end it
    s.toArray (a)->
      expect(a.length == 0)
      done()

  it 'toArray blocks', (done)->
    s = _()
    setTimeout ( -> s.end() ), 20
    m = s.merge()
    m.toArray (a)->
      expect(a.length == 0)
      done()

  it 'merge', (done)->
    ss = _()
    merged = ss.merge()

    s = _()
    ss.write s
    ss.end()

    s.write 1
    s.end()

    merged.toArray (r)->
      expect(r).eql [1]
      done()
