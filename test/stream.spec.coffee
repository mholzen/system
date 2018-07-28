{post, stream} = require '../lib'

it 'should stream a file', ->
  file = await post 'a\nb\n'
  stream.strings(file).toArray (items)->
    expect(items).eql(['a', 'b'])
