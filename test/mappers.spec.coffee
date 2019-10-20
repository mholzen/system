{
  mappers: {
    amount
    columns
    context
    escape
    json
    pick
    string
  }
} = require '../lib'

describe 'mappers', ->

  it 'amount', ->
    expect(amount 1).eql 1
    expect(amount '1').eql 1
    expect(amount amount:1).eql 1
    expect(amount amount:'1').eql 1
    expect(-> amount foo:'1').throws()

  it 'columns', ->
    expect(columns 'a  b      c').eql ['a', 'b', 'c']

  it 'context', ->
    expect(context {path: [1,2,3]}).eql {path:[1]}

  it 'escape', ->
    expect(escape 'a b').eql 'a\\ b'

  it 'json', ->
    expect(json 'a').eql '"a"'
    expect(json a:1).eql '{"a":1}'
    expect(json ['a',1]).eql '["a",1]'

    x = new Map [['a',1]]
    expect(json x).eql '{"a":1}'

    x = new Map [['a',1]]
    expect(json x).eql '{"a":1}'

  it 'pick', ->
    expect(pick {a:1, b:2, c:3}, {0:'a'} ).eql 1
    expect(pick {a:1, b:2, c:3}, {0:'a', 1  :'b'} ).eql {a:1, b:2}

  it 'string', ->
    expect(string 'a').eql 'a'
    expect(string a:1).eql '{"a":1}'
