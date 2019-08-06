args = require '../lib/map/args'

it 'args', ->
  a = args()

  expect a [1,2,3]
  .eql {'0':1, '1':2, '2':3}

  expect a ['a:1', 'b:b', 'c']
  .eql {a:1, b:'b', 2:'c'}

  expect a [{a:1}]
  .eql {'0':{a:1}}
