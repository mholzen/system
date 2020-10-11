{mappers} = require '../../lib'
{
  amount
  columns
  context
  escape
  get
  json
  name
  pick
  string
} = mappers

requireDir = require 'require-dir'
requireDir './mappers'

beforeEach ->
  log.debug '=== new test ==='

describe 'mappers', ->
  it 'is a function', ->
    expect(mappers).a 'function'

  it 'retrieves isLiteral', ->
    f = mappers 'isLiteral'
    expect(f).a 'function'

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
    expect(escape "a'b").eql "a\\'b"
    expect(escape 'a"b').eql 'a\\"b'

  it 'json', ->
    expect(json 'a').eql '"a"'
    expect(json a:1).eql '{"a":1}'
    expect(json ['a',1]).eql '["a",1]'

    x = new Map [['a',1]]
    expect(json x).eql '{"a":1}'

    x = new Map [['a',1]]
    expect(json x).eql '{"a":1}'

  it 'pick', ->
    expect(pick {a:1, b:2}, 'a' ).eql {a:1}
    expect(pick {a:1, b:2, c:3}, 'a', 'b' ).eql {a:1, b:2}
    expect(pick {a:{b:1}}, 'a.b' ).eql {a:{b:1}}

  it 'get', ->
    expect(get {a:1, b:2}, 'a' ).eql 1
    expect(get {a:1, b:2}, 'a', default:0 ).eql 1
    expect(get {a:1, b:2}, 'c', default:0 ).eql 0
    expect(get (new Map [['a', 1]]), 0). eql ['a',1]

  it 'string', ->
    expect(string 'a').eql 'a'
    expect(string a:1).eql '{"a":1}'

  it 'name', ->
    mapper = mappers 'name'
    expect mapper 'John Doe'
    .eql {first: 'John', last: 'Doe'}

    expect mapper 'John'
    .eql {first: 'John'}

    expect mapper 'john.doe'
    .eql {first: 'John', last: 'Doe'}

  it.skip 'multiword last name', ->
    expect name 'marc.von.holzen'
    .eql {first: 'Marc', last:'von Holzen'}