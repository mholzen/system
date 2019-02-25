{post, stream} = require '../lib'
_ = require 'lodash'

it.skip 'should split content', (done)->
  content = 'a\nb\n'
  stream.strings(content).toArray (items)->
    expect(items).eql(['a', 'b'])
    done()

describe 'pickBy', ->
  it.skip 'ignores functions', ->
    class A
      constructor:->
        @a = 1
      f: -> 1
    # o = new A()
    o = stream.highland()
    _.pickBy o, (v,k)->
      console.log k
