{post, stream} = require '../lib'
_ = require 'lodash'

it 'should stream a file', ->
  file = await post 'a\nb\n'
  stream.strings(file).toArray (items)->
    expect(items).eql(['a', 'b'])

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
