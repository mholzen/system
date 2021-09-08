generators = require  'streams/generators'

require './generators/traverse.spec'

describe 'generators', ->
  it 'content', ->
    f = generators 'content'
    expect(f).a 'function'

    s = f path: 'test/artifacts/blurb.txt'
    s.collect().toPromise Promise
    .then (d)->
      expect(d.toString()).eql "A little text file.\nAnother line."

  it 'stats', ->
    stats = generators 'stats'
    expect(stats).a 'function'

    res = stats 'test/artifacts/blurb.txt'
    log {res}
    res.collect().toPromise Promise
    .then (d)->
      expect d
      .property 0
      .property 'stat'
      .respondsTo 'isFile'

  it 'stats', ->
    stats = generators 'stats'
    expect(stats).a 'function'

    res = stats 'test/artifacts/small-directory'
    res.collect().toPromise Promise
    .then (d)->
      # log {r: d.map (x)->x.path }
      expect d
      .length 8
      .property 0
      .property 'stat'
      .respondsTo 'isFile'
