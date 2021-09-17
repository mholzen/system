args = require 'lib/mappers/args'

require '../../lodash.spec'

describe 'args', ->
  it 'handles an object', ->
    expect args {a:1}
    .eql { positional: [], options: {a:1} }

  it 'basic', ->
    expect args [1,2,3]
    .property 'positional'
    .eql [1, 2, 3]

    expect args ['a', 'b', 'c']
    .property 'positional'
    .eql ['a', 'b', 'c']

    expect args ['c', ':', 'a:1', 'b:b']
    .property 'positional'
    .eql ['c']

  it 'options', ->
    expect args 'a:1'
    .property 'options'
    .eql {a:1}

    expect args [{a:1}]
    .property 'options'
    .eql {a:1}

  it 'positional', ->
    expect args ['a:1', 'b:b']
    .property 'positional'
    .eql []

    expect args ['a:1', 'b:b', 'c', 'd:1', 'b']
    .property 'positional'
    .eql ['c', 'b']

    expect args ['a:1', 'b:b', 'c']
    .property 'positional'
    .eql ['c']

    expect args ['a', 'b', 'c:x', 'd:y']
    .property 'positional'
    .eql ['a', 'b']

  it 'positional after dictionary', ->
    expect args ['a:1', 'b:b', 'c', ':']
    .property 'positional'
    .eql ['c']

    expect args '1,2,a:1'
    .eql
      positional: [1,2]
      options: {a:1}

  it 'two levels', ->
    expect args ['a:b:1']
    .property 'options'
    .eql a: b: 1

  describe 'interpet filenames', ->
    it 'two levels with .', ->
      expect args ['a.b:1']   # 'a:b:1' works too
      .property 'options'
      .eql a: b: 1

describe 'terms', ->
  term = args.term
  it 'single term', ->
    expect term 'abc'
    .eql 'abc'

  it 'key:value', ->
    expect term 'a:abc'
    .eql {a: 'abc'}

  it 'value with no key', ->
    expect term ':abc'
    .eql {0: 'abc'}

  it 'key with no value', ->
    expect term 'abc:'
    .eql {abc: ''}

  it 'key with :', ->
    expect term 'a:b:c:abc'
    .eql {a: {b: {c: 'abc'}}}

  it 'key with .', ->
    expect term 'a.b.c:abc'
    .eql {a: {b: {c: 'abc'}}}

  it.skip 'value with .', ->
    expect term 'a:a.b'
    .eql {a: ['a', 'b']}

  it.skip 'key and value with .', ->
    expect term 'a.b:a.b'
    .eql {a: {b: ['a', 'b']}}

  it 'value with #', ->
    expect term 'pug:p%23{options.a}'
    .eql {pug: 'p%23{options.a}'}


{Arguments} = args
describe 'Arguments', ->
  it 'works', ->
    a = Arguments.from 'a,b,c,a:1'

    expect(a.all())
    .eql ['a', 'b', 'c', {a:1}]

    expect(a.options)
    .eql {a:1}

    expect(a.positional)
    .eql ['a', 'b', 'c']

  it 'accepts array', ->
    a = Arguments.from ['a', 'b', 'c', 'a:1']

    expect(a.all())
    .eql ['a', 'b', 'c', {a:1}]

    expect(a.options)
    .eql {a:1}

    expect(a.positional)
    .eql ['a', 'b', 'c']

  it 'turns value with . into positional array', ->
    a = Arguments.from ['a.b', 'd.c']

    expect(a.all())
    .eql [ ['a', 'b'], ['d', 'c'] ]

  it 'validates a signature', ->
    s = Arguments.Signature.from ['a', 'b', 'c']
    expect s.test 'a'
    .eql true

    expect s.test 'd'
    .eql false

    expect s.helper()
    .match /one of.*(a|b|c)/i

  it.skip 'handles edge cases', ->
    a = Arguments.from ':a'
    expect(a.all()).eql ['a', {}]

    a = Arguments.from ':a:2'
    expect(a).eql [{a:2}]

    a = Arguments.from '::2'
    expect(a).eql [{0:2}]

    a = Arguments.from 'a:b:3'
    expect(a).eql []
    expect(a).property('options', {a:{b:3}})

  it 'options can be modified', ->
    a = Arguments.from 'a,b,c,k:1'
    expect(a).property('options').eql {k:1}

  describe 'supports dot', ->
    it '1. means array', ->
      a = Arguments.from 'a.b'
      expect(a.all()).eql [['a', 'b']]

    it '2. means array', ->
      a = Arguments.from 'a.b:1'
      expect(a.all()).eql [{a:{b:1}}]

    it '3. means array', ->
      a = Arguments.from 'a.b,d.e'
      expect(a.all()).eql [['a','b'], ['d','e']]


