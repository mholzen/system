{
  searchers
  stream
  query
  post
  content
} = require '../lib'

describe 'searchers', ->

  it 'entries', ->
    expect(searchers).itself.respondTo 'entries'
    expect(searchers.entries()).length.above 1

  it '()', ->
    # expect(searchers()).itself.respondTo 'entries'
    # expect(Array.from searchers().entries()).length.above 1
    expect(Object.keys searchers()).length.above 1

  it 'inodes, bookmarks', ->
    expect(searchers).property 'inodes'
    expect(searchers).property 'bookmarks'

  it 'combine', ->
    root1 = searchers.inodes '/'
    root2 = searchers.inodes '/'
    roots = stream [ root1, root2 ]
    items = await roots
    .parallel 2
    .collect()
    .toPromise Promise

    expect items
    .length.above 6

  it 'search', ->
    s = searchers.inodes(start:'/').filter (x)-> query('/bin').match x
    items = await s.collect().toPromise Promise
    # expect(items).containing.property 'path', '/bin'
    expect(items.some (i)->i.path == '/bin').true

  it.skip 'search inside', ->
    file = await post 'abc', '/tmp/foo'
    q = query ['foo', 'abc']
    matches = q.match file, partial:true
    matches.each (match)->
      match.value
      match.remainingQuery

    if not q2
      # complete match
      return
    q2.match content file

  it.skip 'search', ->
    files = searchers.inodes()
    q = query 'abc'
    files.flatMap (item)->
      if query.test item
        return stream [ item ]

      q.search2 item, content
