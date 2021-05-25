generators = require  'streams/generators'

requireDir = require 'require-dir'
requireDir './generators'

fs = require 'fs'

describe 'generators', ->
  it 'content', ->
    f = generators 'content'
    expect(f).a 'function'

    s = f path: 'test/artifacts/blurb.txt'
    s.collect().toPromise Promise
    .then (d)->
      expect(d).eql [ ["A little text file.", "Another line."] ]

  it 'stats', ->
    stats = generators 'stats'
    expect(stats).a 'function'

    res = stats 'test/artifacts/blurb.txt'
    res.collect().toPromise Promise
    .then (d)->
      expect d
      .property 0
      .property 'value'
      .respondsTo 'isFile'

  it 'stats', ->
    stats = generators 'stats'
    expect(stats).a 'function'

    res = stats 'test/artifacts/small-directory'
    res.collect().toPromise Promise
    .then (d)->
      log.debug {r: d.map (x)->x.path }
      expect d
      .length 7
      .property 0
      .property 'value'
      .respondsTo 'isFile'
