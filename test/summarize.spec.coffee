{summarize} = require '../lib/mappers'

it 'should summarize', ->
  s = summarize()

  expect s [1,2,3]
  .eql [1,2,3]

  expect s [1,2,3, 4]
  .eql [1,2,3, '...(1 more)']

  expect s [1,2,3,4,5]
  .eql [1,2,3, '...(2 more)']

  expect s [[1,2,3,4,5]]
  .eql [[1,2,3, '...(2 more)']]

  expect s {a:1, b:2, c:3}
  .eql {a:1, b:2, c:3}

  expect s {a:{b:1}}
  .eql {a:{b:1}}

  expect s {a:1, b:2, c:3, d:4}
  .eql {a:1, b:2, c:3, '...': '1 more'}

  expect s {a:{a:1, b:2, c:3, d:4}}
  .eql {a:{a:1, b:2, c:3, '...': '1 more'}}

  expect s {a:[1,2,3,4]}
  .eql {a:[1,2,3, '...(1 more)']}
