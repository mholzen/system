args = require 'lib/mappers/args'

describe 'args', ->
  it 'basic', ->
    expect args [1,2,3]
    .eql {0:1, 1:2, 2:3}

    expect args ['a', 'b', 'c']
    .eql {0:'a', 1:'b', 2:'c'}

    expect args ['a:1', 'b:b', 'c', ':']
    .eql {a:1, b:'b', 2:'c', 3:':'}

    expect args [{a:1}]
    .eql {'0':{a:1}}

    expect args '1,2,a:1'
    .eql {0:1, 1:2, a:1}

    expect args.positional args ['a:1', 'b:b']
    .eql null

    expect args.positional args ['a:1', 'b:b', 'c', 'd:1', 'b']
    .eql ['c', 'b']

    expect args.positional args ['a:1', 'b:b', 'c']
    .eql ['c']

    expect args.positional args ['a', 'b', 'c:x', 'd:y']
    .eql ['a', 'b']


  it.skip 'from string', ->
    expect args.positionalWithOptions 'apply,html,style:name:pretty'
    .eql [
      'apply', 'html', {style:name:'pretty'}
    ]

  it 'two levels', ->
    expect args ['a:b:1']
    .eql a: b: 1

  describe 'interpet filenames', ->
    it.skip 'two levels with .', ->
      expect args ['a.b:1']   # 'a:b:1' works too
      .eql a: b: 1

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
