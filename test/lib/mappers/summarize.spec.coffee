{summarize} = require  'lib/mappers'

describe 'summarize', ->
  it 'should summarize', ->

    expect summarize [1,2,3]
    .eql [1,2,3]

    expect summarize [1,2,3, 4]
    .eql [1,2,3, '...(1 more)']

    expect summarize [1,2,3,4,5]
    .eql [1,2,3, '...(2 more)']

    expect summarize [[1,2,3,4,5]]
    .eql [[1,2,3, '...(2 more)']]

    expect summarize {a:1, b:2, c:3}
    .eql {a:1, b:2, c:3}

    expect summarize {a:{b:1}}
    .eql {a:{b:1}}

    expect summarize {a:1, b:2, c:3, d:4}
    .eql {a:1, b:2, c:3, '...': '1 more'}

    expect summarize {a:{a:1, b:2, c:3, d:4}}
    .eql {a:{a:1, b:2, c:3, '...': '1 more'}}

    expect summarize {a:[1,2,3,4]}
    .eql {a:[1,2,3, '...(1 more)']}
