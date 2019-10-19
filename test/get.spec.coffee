describe.skip 'get', ->

  isReference = (x)->

  it 'get a resource reference', ->
    items = [
      '/bin'
      'http://www.google.com'
      ['/', 'bin']
      {path: ['a', 'b']}
    ].forEach (item)->
      expect(item).satisfy isReference
