args = require '../lib/map/args'

it 'args', ->
  expect args [1,2,3]
  .eql {'0':1, '1':2, '2':3}

  expect args ['a:1', 'b:b', 'c']
  .eql {a:1, b:'b', 2:'c'}

  expect args [{a:1}]
  .eql {'0':{a:1}}
