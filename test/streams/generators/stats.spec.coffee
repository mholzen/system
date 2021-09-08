stats = require 'streams/generators/stats'
{join} = require 'path'

{asyncTraverse} = require 'lib/iterators/traverse'

describe 'streams/generators/stats', ->

  it 'traverse directories', ->
    r = await stats 'test/artifacts/small-directory'
    .collect().toPromise Promise

    expect r.map (x)->x.path
    .log
    .eql [
      []
      ['a'], ['b'], ['c']
      ['dir']
      ['dir', 'aa'], ['dir', 'ab'], ['dir', 'bb']
    ]