{post, stream} = require '../lib'
_ = require 'lodash'

it.skip 'should split content', (done)->
  stream
  .strings 'a\nb\n'
  .toArray (items)->
    expect items
    .eql ['a', 'b']
    done()
