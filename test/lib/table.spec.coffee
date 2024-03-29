{table} = require  'lib'

describe 'table', ->
  it 'should construct from an array of object', ->
    t = new table.Table [{a:1, b:2}, {a:2, c:3}]
    expect(t.keys()).eql ['a','b','c']
    expect(t.rows()).length 2
    expect(t.rows()[0][0]).equal 1
    expect(t.rows()[1][1]).equal undefined
    expect(t.rows()[1][2]).equal 3

  it 'should construct from an array of arrays', ->
    t = new table.Table [['a', 'b'], [1, 2], [3, 4]]
    expect(t.keys()).eql ['a','b']
    expect(t.rows()).eql [[1,2], [3,4]]
    expect(t.column('a')).eql [1,3]