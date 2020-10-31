{summary} = require '../lib/reducers'

it 'summary', ->
  a = [1,2,3]
  [init,reducer] = summary()
  expect a.reduce reducer, init
  .include
    count: 3
