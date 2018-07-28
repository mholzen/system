dates = require '../lib/dates'
query = require '../lib/query'

describe 'dates', ->
  it 'iterator', (done)->
    dates.items.take(1).toArray (items)->
      expect(items[0] instanceof Date).true
      done()

  it 'match', (done)->
    q = new query.Query {name:'dates'}
    expect(q.match dates).true
    dates.items.take(1).toArray (items)->
      expect(items[0] instanceof Date).true
      done()

  it 'partial match', (done)->
    q = new query.Query [{name:'dates'}, 'GMT']
    expect(q.match dates).false
    u = q.nonMatches dates
    expect(u.matches.length).equal 1
    expect(u.match 'GMT').true
    expect(u.match dates).false
    dates.items.take(1).toArray (date)->
      expect(u.toString()).equal 'GMT'
      expect(u.match date).true
      uu = u.nonMatches date
      expect(uu.matches.length).equal 0
      done()
