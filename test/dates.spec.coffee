dates = require  'lib/dates'
query = require  'lib/query'

describe 'dates', ->
  it 'iterator', (done)->
    dates().items.take(2).toArray (items)->
      expect(items[0] instanceof Date).true
      expect(items[1]).above items[0]
      done()

  it.skip 'back pressure', (done)->
    dates().items.each (d)->
      done()

  it.skip 'partial match', (done)->
    q = query [{name:'dates'}, 'GMT']
    expect(q.test dates).false
    u = q.nonMatches dates
    expect(u.matches.length).equal 1
    expect(u.test 'GMT').true
    expect(u.test dates).false
    dates().items.take(1).toArray (date)->
      expect(u.toString()).equal 'GMT'
      expect(u.test date).true
      uu = u.nonMatches date
      expect(uu.matches.length).equal 0
      done()
