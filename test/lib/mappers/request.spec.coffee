{request} = require  'lib/mappers'

describe.skip 'request', ->
  it 'should get a request', ->
    r =  request 'http://www.vonholzen.org'
    expect(r).property('pipe').a 'function'

  it 'should fail to determine a request', ->
    expect(-> request 1).throw('uri')

  it 'should get a body', (done)->
    b = body 'http://www.vonholzen.org'
    b.toArray (b)->
      expect(b[0]).instanceof Buffer
      done()

  it 'should get string', (done)->
    c = string 'http://www.vonholzen.org'
    c.toArray (c)->
      expect(c[0]).includes 'marc von holzen'
      done()

  it 'should get lines', (done)->
    l = lines 'http://www.vonholzen.org'
    l.toArray (l)->
      expect(l.length).greaterThan 5
      done()
