{generators} = require '../lib'
fs = require 'fs'

describe 'generators', ->
  it 'content', ->
    f = generators 'content'
    expect(f).a 'function'

    s = f path: 'test/artifacts/blurb.txt'
    s.collect().toPromise Promise
    .then (d)->
      expect(d).eql [ ["A little text file.", "Another line."] ]

  it.only 'stat', ->
    f = generators 'stat'
    expect(f).a 'function'

    s = f 'test/artifacts/blurb.txt'
    s.collect().toPromise Promise
    .then (d)->
      expect d
      .property 0
      .respondsTo 'isFile'
