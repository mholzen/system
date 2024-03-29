{mappers} = require  'lib'
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

EventEmitter = require 'events'

require 'test/lib/iterators'

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
    expect(amount foo:'1').eql 1

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

  it 'can get which mappers complete, given data', ->
    validate = (entry)->
      [name, f] = entry
      try
        log.debug 'calling mapper', {name}
        r = f 'data'
        if typeof r?.catch == 'function'
          r.catch (e)->
            log.debug 'caught promise rejection', {name, e}
            {}
        if r instanceof EventEmitter
          log.debug 'mapper returned event emitter', {name}
          r.on 'error', ->
            log.debug 'caught error event'

        return name
      catch e
        log.debug 'caught synchronous exception', {name, e}
        return null

    expect Object.entries(mappers.all).map validate
    .log
    .includes 'isLiteral'