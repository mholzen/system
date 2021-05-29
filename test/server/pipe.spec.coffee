Pipe = require 'server/pipe'
root = require 'server/root'

describe 'Pipe', ->
  it 'NotFound handler', ->
    p = new Pipe ['foobar'], root
    expect -> p.processPath {}
    .throws 'NotFound'

  it 'NotFound mapper', ->
    p = new Pipe ['applySync', 'foo'], root
    expect -> p.processPath {}
    .throws 'NotFound'

  it 'NotMapped handler', ->
    p = new Pipe ['applySync', {}], root
    expect -> p.processPath {}
    .throws 'NotMapped'

  it 'literals', ->
    p = new Pipe ['literals', 'a'], root

    expect p.processPath {}
    .eql 'a'

  it 'apply', ->
    p = new Pipe ['literals', 2, 'applySync', 'isLiteral'], root

    expect p.processPath {}
    .eql true

  it 'apply accepts function', ->
    p = new Pipe ['literals', 2, 'applySync', (x)->x+1], root

    expect p.processPath {}
    .eql 3

  it 'mapSync', ->
    p = new Pipe ['literals', '1,2,3', 'mapSync', 'isLiteral'], root

    expect p.processPath {}
    .eql [true, true, true]

  it 'errors within mapSync', ->
    p = new Pipe ['literals', '1,2,3', 'mapSync', (x)->throw new Error('foo') ], root

    expect -> p.processPath {}
    .throws 'foo'


describe.skip 'later', ->

  it 'async', ->
    p = new Pipe ['files', 'cwd', 'test', 'artifacts' ], root
    req = { params: {} }
    res = {}
    await p.processPath req, res
    log.debug {d: req.data}
    expect await req.data
    .log
    .includes 'names.csv'
    .includes 'blurb.html'

  it 'error', ->
    p = new Pipe ['literals', '1', 'map', 'isLiteral'], root
    req = {}
    expect -> p.processPath req
    .throw()
