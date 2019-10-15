{
  mappers: {
    string
    json
  }
} = require '../lib'

describe 'mappers', ->

  it 'string', ->
    map = string()
    expect(map('a')).eql 'a'
    expect(map({a:1})).eql '{"a":1}'

  it 'json', ->
    map = json()
    expect(map('a')).eql '"a"'
    expect(map({a:1})).eql '{"a":1}'
