Pipe = require 'server/pipe'
root = require 'server/root'

describe.skip 'pipe', ->
  describe 'Pipe', ->
    it 'NotFound handler', ->
      p = new Pipe ['foobar'], root
      expect -> p.processPath {}
      .throws 'NotFound'

    it 'NotFound mapper', ->
      p = new Pipe ['applySync', 'foo'], root
      expect -> p.processPath {}
      .throws

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

    it 'object path in root', ->
      p = new Pipe ['a', 'b'], {a: {b: 1}}
      expect p.processPath {}
      .eql 1

    it 'object path in data', ->
      p = new Pipe ['a', 'b']
      req =
        data:
          a:
            b: 1
      expect p.processPath req
      .eql 1

  describe 'async', ->
    it 'object path', ->
      expect root
      .property 'files'
      .property 'cwd'
      p = new Pipe ['files', 'cwd', 'apply', 'resolve'], root
      expect await p.processPath {}
      .property 'then'

  describe.skip 'async', ->
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
