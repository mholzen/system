args = require '../lib/map/args'

describe 'args', ->
  it '()', ->
    f = args()
    expect(f 'a:1', 'b:2').eql [{a:'1'}, {b:'2'}]
