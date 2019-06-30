{summarize} = require '../lib/reducers'

it 'should summarize', ->
  a = [1,2,3]
  reducer = summarize()
  expect a.reduce reducer[1], reducer[0]
  .include
    count: 3
