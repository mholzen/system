{
  mappers: {
    string
    json
    amount
  }
} = require '../lib'

describe 'mappers', ->

  it 'amount', ->
    expect(amount 1).eql 1
    expect(amount '1').eql 1
    expect(amount amount:1).eql 1
    expect(amount amount:'1').eql 1
    expect(-> amount foo:'1').throws()

  it 'json', ->
    map = json()
    expect(map('a')).eql '"a"'
    expect(map({a:1})).eql '{"a":1}'
    expect(map ['a',1]).eql '["a",1]'

    x = new Map [['a',1]]
    expect(map x).eql '{"a":1}'

  it 'string', ->
    map = string()
    expect(map 'a').eql 'a'
    expect(map a:1).eql '{"a":1}'
